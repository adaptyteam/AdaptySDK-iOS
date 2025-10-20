//
//  LifecycleManager.swift
//  AdaptySDK
//
//  Created by Aleksey Goncharov on 27.10.2022.
//

import Foundation
import StoreKit

#if canImport(UIKit)
import UIKit
#endif

private let log = Log.Category(name: "LifecycleManager")

@AdaptyActor
final class LifecycleManager {
    private enum Constants {
        static let appOpenedSendInterval: TimeInterval = 60.0
        static let profileUpdateInterval: TimeInterval = 60.0
        static let profileUpdateShortInterval: TimeInterval = 10.0

        static let profileUpdateAcceleratedInterval: TimeInterval = 3.0
        static let profileUpdateAcceleratedMaxCooldownAfterOpenWeb: TimeInterval = 60.0 * 20.0
        static let profileUpdateAcceleratedDuration: TimeInterval = 60.0 * 5.0

        static let idfaStatusCheckDuration: TimeInterval = 600.0
        static let idfaStatusCheckInterval: TimeInterval = 5.0
    }

    static let shared = LifecycleManager()

    private var appOpenedSentAt: Date?
    private var newStorefrontCountryAvailable: String?

    private var profileUpdateRegularTask: Task<Void, Error>?

    func initialize() {
        log.info("LifecycleManager initialize")

        subscribeForLifecycleEvents()
        subscribeForStorefrontUpdate()
        profileUpdateRegularTask = scheduleProfileUpdate(skipFirstSleep: false)
        scheduleIDFAUpdate()
    }

    private func subscribeForStorefrontUpdate() {
        Task { @AdaptyActor [weak self] in
            for await value in AdaptyStorefront.updates {
                self?.newStorefrontCountryAvailable = value.countryCode
            }
        }
    }

    // MARK: - Sync Profile Logic

    private var profileIsSyncing = false

    private static func calculateProfileUpdateIntervalAndSetLastStartIfNeeded(defaultValue: TimeInterval, logStamp stamp: String) -> TimeInterval {
        guard let storage = Adapty.optionalSDK?.profileStorage else { return defaultValue }

        let now = Date()

        guard let lastOpenedWebPaywallAt = storage.lastOpenedWebPaywallDate() else {
            log.debug("LifecycleManager: \(stamp) calculateInterval: NO WEB PAYWALL")
            return defaultValue
        }

        if let lastStartAcceleratedSyncAt = storage.lastStartAcceleratedSyncProfileDate(), lastStartAcceleratedSyncAt > lastOpenedWebPaywallAt {
            let timeLeft = now.timeIntervalSince(lastStartAcceleratedSyncAt)

            if timeLeft < Constants.profileUpdateAcceleratedDuration {
                log.debug("LifecycleManager: \(stamp) calculateInterval: HAS WEB PAYWALL \(timeLeft) < \(Constants.profileUpdateAcceleratedDuration) (last start)")
                return Constants.profileUpdateAcceleratedInterval
            } else {
                log.debug("LifecycleManager: \(stamp) calculateInterval: HAS WEB PAYWALL \(timeLeft) >= \(Constants.profileUpdateAcceleratedDuration) (last start)")
                return defaultValue
            }
        } else {
            let timeLeftFromLastOpenedWebPaywall = now.timeIntervalSince(lastOpenedWebPaywallAt)

            guard timeLeftFromLastOpenedWebPaywall < Constants.profileUpdateAcceleratedMaxCooldownAfterOpenWeb else {
                log.debug("LifecycleManager: \(stamp) calculateInterval: HAS WEB PAYWALL \(timeLeftFromLastOpenedWebPaywall) >= \(Constants.profileUpdateAcceleratedMaxCooldownAfterOpenWeb) (cooldown)")
                return defaultValue
            }

            log.debug("LifecycleManager: \(stamp) calculateInterval: HAS WEB PAYWALL \(timeLeftFromLastOpenedWebPaywall) < \(Constants.profileUpdateAcceleratedMaxCooldownAfterOpenWeb) (cooldown) -> STORE TIME")

            storage.setLastStartAcceleratedSyncProfileDate()
            return Constants.profileUpdateAcceleratedInterval
        }
    }

    private func scheduleProfileUpdate(skipFirstSleep: Bool) -> Task<Void, Error> {
        let stamp = Log.stamp

        log.verbose("LifecycleManager: \(stamp) scheduleProfileUpdate")

        return Task { @AdaptyActor [weak self] in
            if !skipFirstSleep {
                try await Task.sleep(seconds: Constants.profileUpdateInterval)
            }

            while !Task.isCancelled {
                let defaultUpdateInterval: TimeInterval

                do {
                    try await self?.syncProfile(logStamp: stamp)
                    defaultUpdateInterval = Constants.profileUpdateInterval
                } catch {
                    log.warn("LifecycleManager: \(stamp) syncProfile Error: \(error)")
                    defaultUpdateInterval = Constants.profileUpdateShortInterval
                }

                let updateInterval = Self.calculateProfileUpdateIntervalAndSetLastStartIfNeeded(defaultValue: defaultUpdateInterval, logStamp: stamp)
                log.debug("LifecycleManager: \(stamp) update after: \(updateInterval) sec.")
                try await Task.sleep(seconds: updateInterval)
            }
            throw CancellationError()
        }
    }

    private func syncProfile(logStamp stamp: String) async throws {
        guard !profileIsSyncing else { return }

        defer { profileIsSyncing = false }
        profileIsSyncing = true

        if let storeCountry = newStorefrontCountryAvailable {
            let params = AdaptyProfileParameters(storeCountry: storeCountry)

            log.verbose("LifecycleManager: \(stamp) syncProfile with storeCountry = \(storeCountry)")
            try await Adapty.updateProfile(params: params)
            newStorefrontCountryAvailable = nil
        } else {
            log.verbose("LifecycleManager: \(stamp) syncProfile")
            _ = try await Adapty.getProfile()
        }
    }

    private var crossABIsSyncing = false

    private func syncCrossABState() async throws {
        guard !crossABIsSyncing else { return }

        defer { crossABIsSyncing = false }
        crossABIsSyncing = true

        log.verbose("LifecycleManager: syncCrossPlacementState START")

        for attempt in 0 ..< 3 {
            if attempt > 0 {
                try await Task.sleep(nanoseconds: 1_000_000)
            }

            guard let profileManager = Adapty.optionalSDK?.profileManager else {
                log.verbose("LifecycleManager: syncCrossPlacementState (\(attempt)) SKIP")
                return
            }

            do {
                try await profileManager.syncCrossPlacementState()
                log.verbose("LifecycleManager: syncCrossPlacementState (\(attempt)) SUCCESS")
                break
            } catch {
                log.verbose("LifecycleManager: syncCrossPlacementState (\(attempt)) ERROR: \(error)")
            }
        }
    }

    // MARK: - App Open Event Logic

    private func subscribeForLifecycleEvents() {
        #if canImport(UIKit)
        Task {
            let didBecomeActiveNotification = UIApplication.didBecomeActiveNotification
            NotificationCenter.default.addObserver(
                forName: didBecomeActiveNotification,
                object: nil,
                queue: nil,
                using: handleDidBecomeActiveNotification
            )
        }
        #endif
    }

    @Sendable
    private nonisolated func handleDidBecomeActiveNotification(_: Notification) {
        Task { @AdaptyActor in
            log.verbose("handleDidBecomeActiveNotification")
            Adapty.trackSystemEvent(AdaptyInternalEventParameters(eventName: "app_become_active"))

            profileUpdateRegularTask?.cancel()
            self.profileUpdateRegularTask = self.scheduleProfileUpdate(skipFirstSleep: true)

            Adapty.applicationDidBecomeActive()

            if let appOpenedSentAt, Date().timeIntervalSince(appOpenedSentAt) < Constants.appOpenedSendInterval {
                log.verbose("handleDidBecomeActiveNotification SKIP")
                return
            }
            appOpenedSentAt = Date()

            await Adapty.trackEvent(.appOpened)
            log.verbose("handleDidBecomeActiveNotification track")

            try? await syncCrossABState()
        }
    }

    // MARK: - IDFA Update Logic

    private func scheduleIDFAUpdate() {
        Task { @AdaptyActor in
            let timerStartedAt = Date()

            while true {
                let now = Date()
                if now.timeIntervalSince1970 - timerStartedAt.timeIntervalSince1970 > Constants.idfaStatusCheckDuration {
                    log.verbose("stop IdfaUpdateTimer")
                    return
                }

                let status = await Environment.Device.idfaRetrievalStatus
                log.verbose("idfaUpdateTimer tick, status = \(status)")

                switch status {
                case .allowed:
                    _ = try? await Adapty.getProfile()
                    return
                case .notDetermined:
                    try await Task.sleep(seconds: Constants.idfaStatusCheckInterval)
                case .denied, .notAvailable:
                    return
                }
            }
        }
    }
}

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
    private static let appOpenedSendInterval: TimeInterval = 60.0
    private static let profileUpdateInterval: TimeInterval = 60.0
    private static let profileUpdateShortInterval: TimeInterval = 10.0
    private static let idfaStatusCheckDuration: TimeInterval = 600.0
    private static let idfaStatusCheckInterval: TimeInterval = 5.0

    static let shared = LifecycleManager()

    private var appOpenedSentAt: Date?
    private var newStorefrontCountryAvailable: String?

    func initialize() {
        log.info("LifecycleManager initialize")
        Task {
            await subscribeForLifecycleEvents()
        }
        subscribeForStorefrontUpdate()
        scheduleProfileUpdate()
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

    private func scheduleProfileUpdate() {
        log.verbose("LifecycleManager: scheduleProfileUpdate")

        Task { @AdaptyActor [weak self] in

            try await Task.sleep(seconds: Self.profileUpdateInterval)

            while true {
                let updateInterval: TimeInterval

                do {
                    try await self?.syncProfile()
                    updateInterval = Self.profileUpdateInterval
                } catch {
                    log.warn("LifecycleManager: syncProfile Error: \(error)")
                    updateInterval = Self.profileUpdateShortInterval
                }

                try await Task.sleep(seconds: updateInterval)
            }
        }
    }

    private func syncProfile() async throws {
        guard !profileIsSyncing else { return }

        defer { profileIsSyncing = false }
        profileIsSyncing = true

        if let storeCountry = newStorefrontCountryAvailable {
            let params = AdaptyProfileParameters(storeCountry: storeCountry)

            log.verbose("LifecycleManager: syncProfile with storeCountry = \(storeCountry)")
            try await Adapty.updateProfile(params: params)
            newStorefrontCountryAvailable = nil
        } else {
            log.verbose("LifecycleManager: syncProfile")
            _ = try await Adapty.getProfile()
        }
    }

    // MARK: - App Open Event Logic

    private func subscribeForLifecycleEvents() async {
        #if canImport(UIKit)
            await NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                Task { [weak self] in
                    await self?.handleDidBecomeActiveNotification()
                }
            }
        #endif
    }

    private func handleDidBecomeActiveNotification() async {
        log.verbose("handleDidBecomeActiveNotification")
        Adapty.trackSystemEvent(AdaptyInternalEventParameters(eventName: "app_become_active"))

        if let appOpenedSentAt, Date().timeIntervalSince(appOpenedSentAt) < Self.appOpenedSendInterval {
            log.verbose("handleDidBecomeActiveNotification SKIP")
            return
        }
        appOpenedSentAt = Date()

        Adapty.trackEvent(.appOpened)
        log.verbose("handleDidBecomeActiveNotification track")

        try? await syncProfile()
    }

    // MARK: - IDFA Update Logic

    private func scheduleIDFAUpdate() {
        Task { @AdaptyActor in
            let timerStartedAt = Date()

            while true {
                let now = Date()
                if now.timeIntervalSince1970 - timerStartedAt.timeIntervalSince1970 > Self.idfaStatusCheckDuration {
                    log.verbose("stop IdfaUpdateTimer")
                    return
                }

                let status = await Environment.Device.idfaRetriavalStatus
                log.verbose("idfaUpdateTimer tick, status = \(status)")

                switch status {
                case .allowed:
                    _ = try? await Adapty.getProfile()
                    return
                case .notDetermined:
                    try await Task.sleep(seconds: Self.idfaStatusCheckInterval)
                case .denied, .notAvailable:
                    return
                }
            }
        }
    }
}

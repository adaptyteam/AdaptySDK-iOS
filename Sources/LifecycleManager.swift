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

    static let shared = LifecycleManager()
    static var purchaseInfoUpdateScheduled = false

    private var appOpenedSentAt: Date?
    private var profileSyncAt: Date?

    private var newStorefrontCountryAvailable: String?

    private var initialized = false

    func initialize() {
        guard !initialized else { return }

        log.info("LifecycleManager: initialize")

        subscribeForLifecycleEvents()
        scheduleProfileUpdate(after: Self.profileUpdateInterval)

        Task { [weak self] in
            await self?.scheduleIDFAUpdate()
        }

        Task { [weak self] in
            for await value in AdaptyStorefront.updates {
                self?.newStorefrontCountryAvailable = value.countryCode
            }
        }

        initialized = true
    }

    private func scheduleProfileUpdate(after delay: TimeInterval) {
        guard !Self.purchaseInfoUpdateScheduled else {
            log.verbose("LifecycleManager: scheduleProfileUpdate already scheduled")
            return
        }

        log.verbose("LifecycleManager: scheduleProfileUpdate after \(delay) sec.")

        Self.purchaseInfoUpdateScheduled = true

        Task {
            if delay > 0.0 {
                try await Task.sleep(seconds: delay)
            }

            let success = await syncProfile()

            if success {
                scheduleProfileUpdate(after: success ? Self.profileUpdateInterval : Self.profileUpdateShortInterval)
            }
        }
    }

    private func subscribeForLifecycleEvents() {
        #if canImport(UIKit)
            NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                Task { @AdaptyActor [weak self] in
                    await self?.handleDidBecomeActiveNotification()
                }
            }
        #endif
    }

    private func handleDidBecomeActiveNotification() async {
        Adapty.trackSystemEvent(AdaptyInternalEventParameters(eventName: "app_become_active"))
        log.verbose("LifecycleManager: didBecomeActiveNotification")

        await sendAppOpenedEvent()
        scheduleProfileUpdate(after: 0.0)
    }

    private func syncProfile() async -> Bool {
        if let profileSyncAt,
           Date().timeIntervalSince(profileSyncAt) < Self.profileUpdateInterval
        {
            return false
        }

        log.verbose("LifecycleManager: syncProfile Begin")

        if let storeCountry = newStorefrontCountryAvailable {
            let params = AdaptyProfileParameters(storeCountry: storeCountry)

            do {
                try await Adapty.updateProfile(params: params)
                log.verbose("LifecycleManager: syncProfile Done")

                newStorefrontCountryAvailable = nil
                profileSyncAt = Date()
                return true
            } catch {
                log.warn("LifecycleManager: syncProfile Error: \(error)")
                return false
            }
        } else {
            do {
                try await Adapty.getProfile()
                log.verbose("LifecycleManager: syncProfile Done")
                profileSyncAt = Date()
                return true
            } catch {
                log.warn("LifecycleManager: syncProfile Error: \(error)")
                return false
            }
        }
    }

    private func sendAppOpenedEvent() async {
        if let appOpenedSentAt, Date().timeIntervalSince(appOpenedSentAt) < Self.appOpenedSendInterval {
            log.verbose("LifecycleManager: sendAppOpenedEvent too early")
            return
        }

        log.verbose("LifecycleManager: sendAppOpenedEvent Begin")

        do {
            try await Adapty.trackEvent(.appOpened)
            log.verbose("LifecycleManager: sendAppOpenedEvent Done")
            appOpenedSentAt = Date()
        } catch {
            log.error("LifecycleManager: sendAppOpenedEvent Error: \(error)")
        }
    }

    // MARK: - IDFA Update Logic

    private static let idfaStatusCheckDuration: TimeInterval = 600.0
    private static let idfaStatusCheckInterval: TimeInterval = 5.0
    private var idfaUpdateTimerStartedAt: Date?

    private func scheduleIDFAUpdate() async {
        idfaUpdateTimerStartedAt = Date()
        await idfaUpdateTimerTick()
    }

    private func idfaUpdateTimerTick() async {
        guard let timerStartedAt = idfaUpdateTimerStartedAt else { return }

        let now = Date()
        if now.timeIntervalSince1970 - timerStartedAt.timeIntervalSince1970 > Self.idfaStatusCheckDuration {
            log.verbose("LifecycleManager: stop IdfaUpdateTimer")
            return
        }

        log.verbose("LifecycleManager: idfaUpdateTimer tick")

        guard let needSyncIdfa = await needSyncIdfa else {
            Task {
                try await Task.sleep(seconds: Self.idfaStatusCheckInterval)
                await idfaUpdateTimerTick()
            }
            return
        }

        log.verbose("LifecycleManager: needSyncIdfa = \(needSyncIdfa)")

        if needSyncIdfa {
            Adapty.getProfile { _ in }
        }
    }

    private var needSyncIdfa: Bool? {
        get async {
            guard let adapty = try? Adapty.activatedSDK,
                  let manager = adapty.profileManager
            else {
                return nil
            }

            guard await manager.onceSentEnvironment.needSend(analyticsDisabled: adapty.profileStorage.externalAnalyticsDisabled) else {
                return false
            }
            
            guard await Environment.Device.idfa != nil else { return nil }
            return true
        }
    }
}

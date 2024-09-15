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

final class LifecycleManager {
    private static let underlayQueue = DispatchQueue(label: "Adapty.SDK.Lifecycle")
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
        scheduleIDFAUpdate()

        SKStorefrontManager.subscribeForUpdates { [weak self] countryCode in
            self?.newStorefrontCountryAvailable = countryCode
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

        Self.underlayQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.syncProfile { [weak self] success in
                Self.purchaseInfoUpdateScheduled = false

                self?.scheduleProfileUpdate(after: success ? Self.profileUpdateInterval : Self.profileUpdateShortInterval)
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

                Adapty.logSystemEvent(AdaptyInternalEventParameters(eventName: "app_become_active"))
                log.verbose("LifecycleManager: didBecomeActiveNotification")

                self?.sendAppOpenedEvent()
                self?.scheduleProfileUpdate(after: 0.0)
            }
        #endif
    }

    @objc
    private func syncProfile(completion: @escaping (Bool) -> Void) {
        if let profileSyncAt,
           Date().timeIntervalSince(profileSyncAt) < Self.profileUpdateInterval
        {
            completion(false)
            return
        }

        log.verbose("LifecycleManager: syncProfile Begin")

        if let storeCountry = newStorefrontCountryAvailable {
            Adapty.updateProfile(params: AdaptyProfileParameters(storeCountry: storeCountry)) { [weak self] error in
                if let error {
                    log.verbose("LifecycleManager: syncProfile Error: \(error)")
                    completion(false)
                } else {
                    log.verbose("LifecycleManager: syncProfile Done")

                    self?.newStorefrontCountryAvailable = nil
                    self?.profileSyncAt = Date()
                    completion(true)
                }
            }
        } else {
            Adapty.getProfile { [weak self] result in
                switch result {
                case .success:
                    log.verbose("LifecycleManager: syncProfile Done")
                    self?.profileSyncAt = Date()
                    completion(true)
                case let .failure(error):
                    log.verbose("LifecycleManager: syncProfile Error: \(error)")
                    completion(false)
                }
            }
        }
    }

    private func sendAppOpenedEvent() {
        if let appOpenedSentAt, Date().timeIntervalSince(appOpenedSentAt) < Self.appOpenedSendInterval {
            log.verbose("LifecycleManager: sendAppOpenedEvent too early")
            return
        }

        log.verbose("LifecycleManager: sendAppOpenedEvent Begin")

        Adapty.logAppOpened { [weak self] error in
            if case let .encoding(_, error) = error?.originalError as? EventsError {
                log.error("LifecycleManager: sendAppOpenedEvent Error: \(error)")
            } else if let error {
                log.verbose("LifecycleManager: sendAppOpenedEvent Error: \(error)")
            } else {
                log.verbose("LifecycleManager: sendAppOpenedEvent Done")
                self?.appOpenedSentAt = Date()
            }
        }
    }

    // MARK: - IDFA Update Logic

    private static let idfaStatusCheckDuration: TimeInterval = 600.0
    private static let idfaStatusCheckInterval: Int = 5
    private var idfaUpdateTimerStartedAt: Date?

    private func scheduleIDFAUpdate() {
        idfaUpdateTimerStartedAt = Date()
        idfaUpdateTimerTick()
    }

    private func idfaUpdateTimerTick() {
        guard let timerStartedAt = idfaUpdateTimerStartedAt else { return }

        let now = Date()
        if now.timeIntervalSince1970 - timerStartedAt.timeIntervalSince1970 > Self.idfaStatusCheckDuration {
            log.verbose("LifecycleManager: stop IdfaUpdateTimer")
            return
        }

        log.verbose("LifecycleManager: idfaUpdateTimer tick")

        guard let needSyncIdfa = needSyncIdfa else {
            Self.underlayQueue.asyncAfter(deadline: .now() + .seconds(Self.idfaStatusCheckInterval)) { [weak self] in
                self?.idfaUpdateTimerTick()
            }
            return
        }

        log.verbose("LifecycleManager: needSyncIdfa = \(needSyncIdfa)")

        if needSyncIdfa {
            Adapty.getProfile { _ in }
        }
    }

    private var needSyncIdfa: Bool? {
        guard let adapty = Adapty.shared, let manager = adapty.state.initialized else { return nil }
        guard manager.onceSentEnvironment.needSend(analyticsDisabled: adapty.profileStorage.externalAnalyticsDisabled) else {
            return false
        }
        guard Environment.Device.idfa != nil else { return nil }
        return true
    }
}

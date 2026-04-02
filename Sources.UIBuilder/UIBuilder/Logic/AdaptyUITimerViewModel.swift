//
//  AdaptyUITimerViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 04.06.2024.
//

import SwiftUI

#if canImport(UIKit)

@MainActor
package struct AdaptyUIDefaultTimerResolver: AdaptyUITimerResolver {
    package init() {}

    package func timerEndAtDate(for _: String) -> Date {
        Date(timeIntervalSinceNow: 3600.0)
    }
}

extension [String: Date]: AdaptyUITimerResolver {
    public func timerEndAtDate(for timerId: String) -> Date {
        self[timerId] ?? Date(timeIntervalSinceNow: 3600.0)
    }
}

@MainActor
package protocol AdaptyUITimerCallbackHandler: AnyObject {
    func handleTimerCallback(timerId: String, callback: VS.JSAction)
}

@MainActor
package final class AdaptyUITimerViewModel: ObservableObject {
    private let logId: String

    private static var globalTimers = [String: Date]()
    private var timers = [String: Date]()

    private let timerResolver: AdaptyUITimerResolver

    private let stateViewModel: AdaptyUIStateViewModel
    private let paywallViewModel: AdaptyUIPaywallViewModel
    private let productsViewModel: AdaptyUIProductsViewModel
    private let screensViewModel: AdaptyUIScreensViewModel

    private var timerCallbacks: [String: VS.JSAction] = [:]
    private var centralTimer: Timer?
    package weak var callbackHandler: AdaptyUITimerCallbackHandler?

    package init(
        logId: String,
        timerResolver: AdaptyUITimerResolver,
        stateViewModel: AdaptyUIStateViewModel,
        paywallViewModel: AdaptyUIPaywallViewModel,
        productsViewModel: AdaptyUIProductsViewModel,
        screensViewModel: AdaptyUIScreensViewModel
    ) {
        self.logId = logId
        self.timerResolver = timerResolver
        self.stateViewModel = stateViewModel
        self.paywallViewModel = paywallViewModel
        self.productsViewModel = productsViewModel
        self.screensViewModel = screensViewModel
    }

    func setEndDate(id: String, date: Date, callback: VS.JSAction?) {
        Log.ui.verbose("#\(logId)# setTimer id: \(id), endAt: \(date)")
        timers[id] = date
        if let callback { timerCallbacks[id] = callback }
        objectWillChange.send()
        startCentralTimerIfNeeded()
    }

    func setDuration(id: String, duration: TimeInterval, behavior: VC.SetTimerBehavior, callback: VS.JSAction?) {
        Log.ui.verbose("#\(logId)# setTimer id: \(id), duration: \(duration), behavior: \(behavior)")
        if let callback { timerCallbacks[id] = callback }
        startCentralTimerIfNeeded()

        switch behavior {
        case .restart:
            let endAt = Date(timeIntervalSinceNow: duration)
            timers[id] = endAt

        case .continue:
            if let existing = timers[id], existing.timeIntervalSinceNow > 0 {
                return
            }
            if let globalEndAt = Self.globalTimers[id], globalEndAt.timeIntervalSinceNow > 0 {
                timers[id] = globalEndAt
            } else {
                let endAt = Date(timeIntervalSinceNow: duration)
                timers[id] = endAt
                Self.globalTimers[id] = endAt
            }

        case .persisted:
            let key = "AdaptySDK_Timer_\(id)"
            if let persistedTs = UserDefaults.standard.value(forKey: key) as? TimeInterval {
                let endAt = Date(timeIntervalSince1970: persistedTs)
                if endAt.timeIntervalSinceNow > 0 {
                    timers[id] = endAt
                    return
                }
            }
            let endAt = Date(timeIntervalSinceNow: duration)
            timers[id] = endAt
            UserDefaults.standard.set(endAt.timeIntervalSince1970, forKey: key)

        case .custom:
            let resolved = timerResolver.timerEndAtDate(for: id)
            timers[id] = resolved
        }

        objectWillChange.send()
    }

    func timeLeft(
        for timer: VC.Timer,
        at: Date,
        screen: VS.ScreenInstance
    ) -> TimeInterval {
        guard let timerEndAt = timers[timer.id] else {
            return 0.0
        }

        let timeLeft = max(0.0, timerEndAt.timeIntervalSince1970 - Date().timeIntervalSince1970)

        if timeLeft <= 0.0 {
            stateViewModel.execute(actions: timer.actions, screen: screen)
        }

        return timeLeft
    }

    package func resetTimersState() {
        Log.ui.verbose("#\(logId)# resetTimersState")
        timers.removeAll()
        timerCallbacks.removeAll()
        stopCentralTimer()
    }

    // MARK: - Central Timer Loop

    private func startCentralTimerIfNeeded() {
        guard centralTimer == nil else { return }
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.current.add(timer, forMode: .common)
        centralTimer = timer
    }

    private func tick() {
        objectWillChange.send()
        checkExpiredCallbacks()
        stopCentralTimerIfIdle()
    }

    private func checkExpiredCallbacks() {
        let now = Date()
        for (id, endDate) in timers where timerCallbacks[id] != nil {
            if endDate.timeIntervalSince(now) <= 0 {
                if let callback = timerCallbacks.removeValue(forKey: id) {
                    callbackHandler?.handleTimerCallback(
                        timerId: id,
                        callback: callback
                    )
                }
            }
        }
    }

    private func stopCentralTimerIfIdle() {
        let hasActiveTimers = timers.values.contains { $0.timeIntervalSinceNow > 0 }
        if !hasActiveTimers && timerCallbacks.isEmpty {
            centralTimer?.invalidate()
            centralTimer = nil
        }
    }

    private func stopCentralTimer() {
        centralTimer?.invalidate()
        centralTimer = nil
    }
}

#endif


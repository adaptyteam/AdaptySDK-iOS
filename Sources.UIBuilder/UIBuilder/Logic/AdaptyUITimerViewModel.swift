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

    package func timerEndAtDate(for timerId: String) -> Date {
        Date(timeIntervalSinceNow: 3600.0)
    }
}

extension [String: Date]: AdaptyUITimerResolver {
    public func timerEndAtDate(for timerId: String) -> Date {
        self[timerId] ?? Date(timeIntervalSinceNow: 3600.0)
    }
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
    private let sectionsViewModel: AdaptyUISectionsViewModel
    private let screensViewModel: AdaptyUIScreensViewModel

    package init(
        logId: String,
        timerResolver: AdaptyUITimerResolver,
        stateViewModel: AdaptyUIStateViewModel,
        paywallViewModel: AdaptyUIPaywallViewModel,
        productsViewModel: AdaptyUIProductsViewModel,
        sectionsViewModel: AdaptyUISectionsViewModel,
        screensViewModel: AdaptyUIScreensViewModel
    ) {
        self.logId = logId
        self.timerResolver = timerResolver
        self.stateViewModel = stateViewModel
        self.paywallViewModel = paywallViewModel
        self.productsViewModel = productsViewModel
        self.sectionsViewModel = sectionsViewModel
        self.screensViewModel = screensViewModel
    }

    private func initializeTimer(_ timer: VC.Timer, at: Date) -> Date {
        switch timer.state {
        case let .endedAt(endAt):
            timers[timer.id] = endAt
            return endAt
        case let .duration(duration, startBehaviour):
            switch startBehaviour {
            case .everyAppear:
                let endAt = Date(timeIntervalSince1970: at.timeIntervalSince1970 + duration)
                timers[timer.id] = endAt
                return endAt
            case .firstAppear:
                if let globalEndAt = Self.globalTimers[timer.id] {
                    timers[timer.id] = globalEndAt
                    return globalEndAt
                } else {
                    let endAt = Date(timeIntervalSince1970: at.timeIntervalSince1970 + duration)
                    timers[timer.id] = endAt
                    Self.globalTimers[timer.id] = endAt
                    return endAt
                }
            case .firstAppearPersisted:
                let key = "AdaptySDK_Timer_\(timer.id)"

                if let persistedEndAtTs = UserDefaults.standard.value(forKey: key) as? TimeInterval {
                    let endAt = Date(timeIntervalSince1970: persistedEndAtTs)
                    timers[timer.id] = endAt
                    return endAt
                } else {
                    let endAt = Date(timeIntervalSince1970: at.timeIntervalSince1970 + duration)
                    timers[timer.id] = endAt
                    UserDefaults.standard.set(endAt.timeIntervalSince1970, forKey: key)
                    return endAt
                }
            case .custom:
                let resolved = timerResolver.timerEndAtDate(for: timer.id)
                timers[timer.id] = resolved
                return resolved
            }
        }
    }

    func timeLeft(
        for timer: VC.Timer,
        at: Date,
        screen: VC.ScreenInstance
    ) -> TimeInterval {
        let timerEndAt = timers[timer.id] ?? initializeTimer(timer, at: at)
        let timeLeft = max(0.0, timerEndAt.timeIntervalSince1970 - Date().timeIntervalSince1970)

        if timeLeft <= 0.0 {
            stateViewModel.execute(actions: timer.actions, screen: screen)
        }

        return timeLeft
    }

    package func resetTimersState() {
        Log.ui.verbose("#\(logId)# resetTimersState")
        timers.removeAll()
    }
}

#endif

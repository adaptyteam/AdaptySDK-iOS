//
//  AdaptyTimerViewModel.swift
//
//
//  Created by Aleksey Goncharov on 04.06.2024.
//

import SwiftUI

@MainActor
package struct AdaptyUIDefaultTimerResolver: AdaptyTimerResolver {
    package init() {}

    package func timerEndAtDate(for timerId: String) -> Date {
        Date(timeIntervalSinceNow: 3600.0)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension [String: Date]: AdaptyTimerResolver {
    public func timerEndAtDate(for timerId: String) -> Date {
        self[timerId] ?? Date(timeIntervalSinceNow: 3600.0)
    }
}

#if canImport(UIKit)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptyTimerViewModel: ObservableObject {
    private let logId: String

    private static var globalTimers = [String: Date]()
    private var timers = [String: Date]()

    private let timerResolver: AdaptyTimerResolver

    private let paywallViewModel: AdaptyPaywallViewModel
    private let productsViewModel: AdaptyProductsViewModel
    private let actionsViewModel: AdaptyUIActionsViewModel
    private let sectionsViewModel: AdaptySectionsViewModel
    private let screensViewModel: AdaptyScreensViewModel

    package init(
        logId: String,
        timerResolver: AdaptyTimerResolver,
        paywallViewModel: AdaptyPaywallViewModel,
        productsViewModel: AdaptyProductsViewModel,
        actionsViewModel: AdaptyUIActionsViewModel,
        sectionsViewModel: AdaptySectionsViewModel,
        screensViewModel: AdaptyScreensViewModel
    ) {
        self.logId = logId
        self.timerResolver = timerResolver
        self.paywallViewModel = paywallViewModel
        self.productsViewModel = productsViewModel
        self.actionsViewModel = actionsViewModel
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
                timers[timer.id] = timerResolver.timerEndAtDate(for: timer.id)
                return at
            }
        }
    }

    func timeLeft(
        for timer: VC.Timer,
        at: Date,
        screenId: String
    ) -> TimeInterval {
        let timerEndAt = timers[timer.id] ?? initializeTimer(timer, at: at)
        let timeLeft = max(0.0, timerEndAt.timeIntervalSince1970 - Date().timeIntervalSince1970)

        if timeLeft <= 0.0 {
            timer.actions.fire(
                screenId: screenId,
                paywallViewModel: paywallViewModel,
                productsViewModel: productsViewModel,
                actionsViewModel: actionsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
        }

        return timeLeft
    }

    package func resetTimersState() {
        Log.ui.verbose("#\(logId)# resetTimersState")
        timers.removeAll()
    }
}

#endif

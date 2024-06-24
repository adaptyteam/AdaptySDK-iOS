//
//  AdaptyTimerViewModel.swift
//
//
//  Created by Aleksey Goncharov on 04.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
package class AdaptyTimerViewModel: ObservableObject {
    private static var globalTimers = [String: Date]()
    private var timers = [String: Date]()
    
    private let productsViewModel: AdaptyProductsViewModel
    private let actionsViewModel: AdaptyUIActionsViewModel
    private let sectionsViewModel: AdaptySectionsViewModel
    private let screensViewModel: AdaptyScreensViewModel
    
    package init(
        productsViewModel: AdaptyProductsViewModel,
        actionsViewModel: AdaptyUIActionsViewModel,
        sectionsViewModel: AdaptySectionsViewModel,
        screensViewModel: AdaptyScreensViewModel
    ) {
        self.productsViewModel = productsViewModel
        self.actionsViewModel = actionsViewModel
        self.sectionsViewModel = sectionsViewModel
        self.screensViewModel = screensViewModel
    }

    private func initializeTimer(_ timer: AdaptyUI.Timer, at: Date) -> Date {
        switch timer.state {
        case let .endedAt(endAt):
            timers[timer.id] = endAt
            return endAt
        case let .duration(duration, start: startBehaviour):
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
                // TODO: implement delegate method
                timers[timer.id] = at
                return at
            }
        }
    }

    func timeLeft(
        for timer: AdaptyUI.Timer,
        at: Date,
        screenId: String
    ) -> TimeInterval {
        let timerEndAt = timers[timer.id] ?? initializeTimer(timer, at: at)
        let timeLeft = max(0.0, timerEndAt.timeIntervalSince1970 - Date().timeIntervalSince1970)
        
        if timeLeft <= 0.0, let action = timer.action {
            action.fire(
                screenId: screenId,
                productsViewModel: productsViewModel,
                actionsViewModel: actionsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
        }
        
        return timeLeft
    }
}

#endif

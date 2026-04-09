//
//  AdaptyUINavigatorViewModel.swift
//  Adapty
//
//  Created by Alex Goncharov on 11/02/2026.
//

#if canImport(UIKit)

import Foundation
import SwiftUI

@MainActor
final class AdaptyUIScreenViewModel: ObservableObject {
    var id: String { instance.id }
    var configuration: VC.Screen { instance.configuration }

    let instance: VS.ScreenInstance
    var zIndex: Double = 1.0
    var transitionId: String?

    @Published var playIncomingTransition: [VC.Animation]? = nil
    @Published var playOutgoingTransition: [VC.Animation]? = nil

    init(
        instance: VS.ScreenInstance
    ) {
        self.instance = instance
    }

    func startIncomingTransition(_ animations: [VC.Animation]?) {
        playIncomingTransition = animations
    }

    func startOutgoingTransition(_ animations: [VC.Animation]?) {
        playOutgoingTransition = animations
    }
}

@MainActor
package final class AdaptyUINavigatorViewModel: ObservableObject {
    let navigator: VC.Navigator
    let appearTransitionId: String
    let logId: String

    var id: VC.NavigatorIdentifier { navigator.id }
    var order: Double { Double(navigator.order) }

    var initialBackground: VC.AssetReference? {
        appearTransition?.background?.initialBackground ?? navigator.background
    }
    
    var appearTransition: VC.Navigator.AppearanceTransition? {
        navigator.appearances?[appearTransitionId]
    }

    let eventBus = AdaptyUIEventBus()

    /// Callback for executing screen-level lifecycle actions
    var executeActions: ((_ actions: [VC.Action], _ screen: VS.ScreenInstance) -> Void)?

    @Published
    private(set) var screens: [AdaptyUIScreenViewModel]

    var currentScreenInstanceIfSingle: VS.ScreenInstance? {
        screens.firstIfSingle?.instance
    }

    init(
        logId: String,
        navigator: VC.Navigator,
        screen: AdaptyUIScreenViewModel,
        appearTransitionId: String
    ) {
        self.logId = logId
        self.navigator = navigator
        self.appearTransitionId = appearTransitionId

        screens = [screen]
    }

    @Published var backgroundAnimation: VC.Animation.Background? = nil
    @Published var contentAnimations: [VC.Animation]? = nil

    func startScreenTransition(
        _ screen: AdaptyUIScreenViewModel,
        transitionId: String,
        completion: (() -> Void)?
    ) {
        Log.ui.verbose("#\(logId)# startScreenTransition screen:\(screen.id) in navigator:\(navigator.id)")

        guard var currentScreen = screens.firstIfSingle else {
            // TODO: x throw error?
            Log.ui.error("#\(logId)# navigator:\(navigator.id) has animations in progress")
            return // in the process of animation, TODO: x think about force replacement?
        }

        guard currentScreen.id != screen.id else {
            Log.ui.error("#\(logId)# screen:\(screen.id) is already presented in navigator:\(navigator.id)")
            return // TODO: x throw error?
        }

        // Fire onWillDisappear for outgoing screen
        executeScreenActions(.onWillDisappear, screen: currentScreen.instance)
        eventBus.publish(
            eventId: .onWillDisappear,
            transitionId: transitionId,
            screenInstanceId: currentScreen.instance.id
        )

        guard let transition = navigator.transitions?[transitionId] else {
            Log.ui.verbose("#\(logId)# screen:\(screen.id) in navigator:\(navigator.id) - no transition found")

            screens.removeAll()

            screen.transitionId = transitionId
            screens.append(screen)

            // Fire onWillAppear for incoming screen (no transition)
            executeScreenActions(.onWillAppear, screen: screen.instance)
            eventBus.publish(
                eventId: .onWillAppear,
                transitionId: transitionId,
                screenInstanceId: screen.instance.id
            )

            completion?()

            // Fire onDidAppear immediately (no transition to wait for)
            executeScreenActions(.onDidAppear, screen: screen.instance)
            eventBus.publish(
                eventId: .onDidAppear,
                transitionId: transitionId,
                screenInstanceId: screen.instance.id
            )

            return
        }

        Log.ui.verbose("#\(logId)# screen:\(screen.id) in navigator:\(navigator.id) - transition found")

        var newScreen = screen
        newScreen.transitionId = transitionId

        currentScreen.startOutgoingTransition(transition.outgoing)
        newScreen.startIncomingTransition(transition.incoming)

        // Fire onWillAppear for incoming screen
        executeScreenActions(.onWillAppear, screen: newScreen.instance)
        eventBus.publish(
            eventId: .onWillAppear,
            transitionId: transitionId,
            screenInstanceId: newScreen.instance.id
        )

        screens.append(newScreen)

        DispatchQueue.main.asyncAfter(
            deadline: .now() + transition.totalDuration
        ) { [weak self] in
            guard let self else { return }

            Log.ui.verbose("#\(self.logId)# screen:\(screen.id) in navigator:\(self.navigator.id) - transition finished")

            // Fire onDidDisappear for outgoing screen
            self.executeScreenActions(.onDidDisappear, screen: currentScreen.instance)

            // Clear stale pending events for outgoing screen
            self.eventBus.clearPending(for: currentScreen.instance.id)

            self.screens.remove(at: 0)
            completion?()

            // Fire onDidAppear for the new screen
            self.executeScreenActions(.onDidAppear, screen: screen.instance)
            self.eventBus.publish(
                eventId: .onDidAppear,
                transitionId: transitionId,
                screenInstanceId: screen.instance.id
            )
        }
    }

    func startNavigatorTransition(
        transitionId: String,
        completion: (() -> Void)?
    ) {
        Log.ui.verbose("#\(logId)# startNavigatorTransition \(transitionId) in navigator:\(navigator.id)")

        // Fire onWillAppear for navigator-level elements
        eventBus.publish(
            eventId: .onWillAppear,
            transitionId: transitionId,
            screenInstanceId: nil
        )

        // Fire onWillAppear for the initial screen
        if let screen = screens.first {
            screen.transitionId = transitionId
            executeScreenActions(.onWillAppear, screen: screen.instance)
            eventBus.publish(
                eventId: .onWillAppear,
                transitionId: transitionId,
                screenInstanceId: screen.instance.id
            )
        }

        guard let transition = navigator.appearances?[transitionId] else {
            Log.ui.verbose("#\(logId)# navigator:\(navigator.id) - no transition found")
            completion?()

            // Fire onDidAppear immediately (no transition)
            eventBus.publish(
                eventId: .onDidAppear,
                transitionId: transitionId,
                screenInstanceId: nil
            )
            if let screen = screens.first {
                executeScreenActions(.onDidAppear, screen: screen.instance)
                eventBus.publish(
                    eventId: .onDidAppear,
                    transitionId: transitionId,
                    screenInstanceId: screen.instance.id
                )
            }

            return
        }

        backgroundAnimation = transition.background
        contentAnimations = transition.content

        let totalDuration = transition.totalDuration

        DispatchQueue.main.asyncAfter(
            deadline: .now() + totalDuration
        ) { [weak self] in
            guard let self else { return }
            Log.ui.verbose("#\(self.logId)# navigator:\(self.navigator.id) - transition finished")

            completion?()

            // Fire onDidAppear after transition completes
            self.eventBus.publish(
                eventId: .onDidAppear,
                transitionId: transitionId,
                screenInstanceId: nil
            )
            if let screen = self.screens.first {
                self.executeScreenActions(.onDidAppear, screen: screen.instance)
                self.eventBus.publish(
                    eventId: .onDidAppear,
                    transitionId: transitionId,
                    screenInstanceId: screen.instance.id
                )
            }
        }
    }

    func publishDismissEvents() {
        if let screen = screens.last {
            executeScreenActions(.onWillDisappear, screen: screen.instance)
            eventBus.publish(
                eventId: .onWillDisappear,
                transitionId: nil,
                screenInstanceId: screen.instance.id
            )
        }
        eventBus.publish(
            eventId: .onWillDisappear,
            transitionId: nil,
            screenInstanceId: nil
        )
    }

    func executeScreenActions(_ eventId: VC.EventHandler.EventId, screen: VS.ScreenInstance) {
        let actions: [VC.Action]? = switch eventId {
        case .onWillAppear:
            navigator.defaultScreenActions.onWillAppear ?? screen.configuration.screenActions.onWillAppear
        case .onDidAppear:
            navigator.defaultScreenActions.onDidAppear ?? screen.configuration.screenActions.onDidAppear
        case .onWillDisappear:
            navigator.defaultScreenActions.onWillDisappear ?? screen.configuration.screenActions.onWillDisappear
        case .onDidDisappear:
            navigator.defaultScreenActions.onDidDisappear ?? screen.configuration.screenActions.onDidDisappear
        default:
            nil
        }
        if let actions, !actions.isEmpty {
            executeActions?(actions, screen)
        }
    }
}

// TODO: x move out
extension VC.Animation.Background {
    var initialBackground: VC.AssetReference {
        range.start
    }
}

extension VC.Navigator.AppearanceTransition {
    var totalDuration: TimeInterval {
        let backgroundTimeline: [VC.Animation.Timeline] = if let background { [background.timeline] } else { [] }

        return
            (backgroundTimeline + (content?.map(\.timeline) ?? []))
                .map { $0.duration + $0.startDelay }
                .max { $0 > $1 } ?? 0.0
    }

    var initialContentOpacity: Double {
        content?
            .compactMap {
                if case let .opacity(timeline, range) = $0 {
                    return (timeline: timeline, range: range)
                } else {
                    return nil
                }
            }
            .min(by: { lhs, rhs in lhs.timeline.startDelay < rhs.timeline.startDelay })
            .map { $0.range.start } ?? 1.0
    }

    var initialContentOffset: VC.Offset {
        content?
            .compactMap {
                if case let .offset(timeline, range) = $0 {
                    return (timeline: timeline, range: range)
                } else {
                    return nil
                }
            }
            .min(by: { lhs, rhs in lhs.timeline.startDelay < rhs.timeline.startDelay })
            .map { $0.range.start } ?? .zero
    }
}

extension VC.Navigator.ScreenTransition {
    var totalDuration: TimeInterval {
        ((incoming ?? []) + (outgoing ?? [])).totalDuration
    }
}

extension [VC.Animation] {
    var totalDuration: TimeInterval {
        map(\.timeline)
            .map { $0.duration + $0.startDelay }
            .max { $0 > $1 } ?? 0.0
    }
}

#endif

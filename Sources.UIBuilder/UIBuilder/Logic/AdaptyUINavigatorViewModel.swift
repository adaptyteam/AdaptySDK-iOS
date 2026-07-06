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
    var id: String {
        instance.id
    }

    var configuration: VC.Screen {
        instance.configuration
    }

    let instance: VS.ScreenInstance
    var zIndex: Double = 1.0
    var transitionId: String?

    @Published var playIncomingTransition: [VC.Animation]? = nil
    @Published var playOutgoingTransition: [VC.Animation]? = nil

    /// Drained by AdaptyScreenView's .onAppear so onDidAppear script-actions
    /// run after SwiftUI has rendered the screen's first body.
    var pendingFireOnDidAppear: (() -> Void)?

    init(
        instance: VS.ScreenInstance
    ) {
        self.instance = instance
    }

    func consumeFireOnDidAppear() {
        let pending = pendingFireOnDidAppear
        pendingFireOnDidAppear = nil
        pending?()
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
    let isRightToLeft: Bool
    let logId: String

    var id: VC.NavigatorIdentifier {
        navigator.id
    }

    var order: Double {
        Double(navigator.order)
    }

    var initialBackground: VC.AssetReference? {
        appearTransition?.background?.initialBackground ?? navigator.background
    }

    var appearTransition: VC.Navigator.AppearanceTransition? {
        navigator.appearanceTransition(id: appearTransitionId, isRightToLeft: isRightToLeft)
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
        appearTransitionId: String,
        isRightToLeft: Bool
    ) {
        self.logId = logId
        self.navigator = navigator
        self.appearTransitionId = appearTransitionId
        self.isRightToLeft = isRightToLeft

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

        guard let currentScreen = screens.firstIfSingle else {
            // A transition is mid-flight (more than one screen in the stack).
            // The incoming request is intentionally dropped rather than queued
            // or force-applied: replacing a screen mid-animation would leave the
            // transition's deferred cleanup (see asyncAfter below) acting on a
            // stale screen. Dropping is the safe behavior for release.
            Log.ui.error("#\(logId)# navigator:\(navigator.id) has animations in progress")
            return
        }

        guard currentScreen.id != screen.id else {
            // Idempotent re-request: the screen is already the single presented
            // screen. Nothing to transition to, so this is a no-op, not an error.
            Log.ui.warn("#\(logId)# screen:\(screen.id) is already presented in navigator:\(navigator.id)")
            return
        }

        // Fire onWillDisappear for outgoing screen
        executeScreenActions(.onWillDisappear, screen: currentScreen.instance)
        eventBus.publish(
            eventId: .onWillDisappear,
            transitionId: transitionId,
            screenInstanceId: currentScreen.instance.id
        )

        guard let transition = navigator.screenTransition(id: transitionId, isRightToLeft: isRightToLeft) else {
            Log.ui.verbose("#\(logId)# screen:\(screen.id) in navigator:\(navigator.id) - no transition found")

            executeScreenActions(.onDidDisappear, screen: currentScreen.instance)
            eventBus.clearPending(for: currentScreen.instance.id)

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

            // Defer onDidAppear to AdaptyScreenView's .onAppear so screen
            // actions that mutate state (e.g. flipping a progress value from
            // 0 to 1) run after the screen's first body, not before it.
            screen.pendingFireOnDidAppear = { [weak self, weak screen] in
                guard let self, let screen else { return }
                self.executeScreenActions(.onDidAppear, screen: screen.instance)
                self.eventBus.publish(
                    eventId: .onDidAppear,
                    transitionId: transitionId,
                    screenInstanceId: screen.instance.id
                )
            }

            return
        }

        Log.ui.verbose("#\(logId)# screen:\(screen.id) in navigator:\(navigator.id) - transition found")

        let newScreen = screen
        newScreen.transitionId = transitionId

        if !transition.isIncomingOnTop {
            newScreen.zIndex = 0.0
        }

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

        // Extra 0.1s buffer accounts for the delay between when the timer
        // starts and when SwiftUI actually begins rendering the animations
        // (view update pipeline: onReceive → onChange → startAnimations → Task).
        DispatchQueue.main.asyncAfter(
            deadline: .now() + transition.totalDuration + 0.1
        ) { [weak self] in
            guard let self else { return }

            Log.ui.verbose("#\(self.logId)# screen:\(screen.id) in navigator:\(self.navigator.id) - transition finished")

            // Fire onDidDisappear for outgoing screen
            self.executeScreenActions(.onDidDisappear, screen: currentScreen.instance)

            // Clear stale pending events for outgoing screen
            self.eventBus.clearPending(for: currentScreen.instance.id)

            self.screens.remove(at: 0)
            self.screens.first?.zIndex = 1.0
            completion?()

            // TODO: SDK-1043 — disarming armed @Published values after the
            // animation deadline is fragile: if the app is backgrounded
            // mid-transition (or the view tree remounts before this fires),
            // re-subscribers will still receive the armed value and replay
            // the animation. Replace with a one-shot signal (e.g. UUID
            // nonce) so transition triggers fire exactly once regardless of
            // re-subscriptions. Also applies to startNavigatorTransition
            // (backgroundAnimation / contentAnimations) below. Investigate
            // the orthogonal issue of why AdaptyNavigatorView remounts
            // twice on app foreground.
            currentScreen.startOutgoingTransition(nil)
            screen.startIncomingTransition(nil)

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

        guard let transition = navigator.appearanceTransition(id: transitionId, isRightToLeft: isRightToLeft) else {
            Log.ui.verbose("#\(logId)# navigator:\(navigator.id) - no transition found")
            completion?()

            // Defer onDidAppear to AdaptyScreenView's .onAppear (see
            // startScreenTransition for the rationale).
            if let screen = screens.first {
                screen.pendingFireOnDidAppear = { [weak self, weak screen] in
                    guard let self, let screen else { return }
                    self.eventBus.publish(
                        eventId: .onDidAppear,
                        transitionId: transitionId,
                        screenInstanceId: nil
                    )
                    self.executeScreenActions(.onDidAppear, screen: screen.instance)
                    self.eventBus.publish(
                        eventId: .onDidAppear,
                        transitionId: transitionId,
                        screenInstanceId: screen.instance.id
                    )
                }
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

            self.backgroundAnimation = nil
            self.contentAnimations = nil

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
            screen.configuration.screenActions.onWillAppear ?? navigator.defaultScreenActions.onWillAppear
        case .onDidAppear:
            screen.configuration.screenActions.onDidAppear ?? navigator.defaultScreenActions.onDidAppear
        case .onWillDisappear:
            screen.configuration.screenActions.onWillDisappear ?? navigator.defaultScreenActions.onWillDisappear
        case .onDidDisappear:
            screen.configuration.screenActions.onDidDisappear ?? navigator.defaultScreenActions.onDidDisappear
        default:
            nil
        }
        if let actions, !actions.isEmpty {
            executeActions?(actions, screen)
        }
    }
}

#endif

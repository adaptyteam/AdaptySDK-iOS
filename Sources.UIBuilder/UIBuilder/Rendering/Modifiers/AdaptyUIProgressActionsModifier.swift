//
//  AdaptyUIProgressActionsModifier.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 19.05.2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIProgressActionsModifier: ViewModifier {
    private let actions: [VC.Action]
    private let transition: VC.Transition
    private let value: Double

    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel

    @State private var pendingAction: DispatchWorkItem?

    init(actions: [VC.Action], transition: VC.Transition, value: Double) {
        self.actions = actions
        self.transition = transition
        self.value = value
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _ in
                fireActionsWhenTransitionEnds()
            }
            .onDisappear {
                pendingAction?.cancel()
                pendingAction = nil
            }
    }

    private func fireActionsWhenTransitionEnds() {
        pendingAction?.cancel()
        pendingAction = nil
        guard !actions.isEmpty else { return }
        let totalDelay = transition.startDelay + transition.duration
        let actions = self.actions
        let screen = self.screen
        if totalDelay > 0 {
            let work = DispatchWorkItem { [weak stateViewModel] in
                stateViewModel?.execute(actions: actions, screen: screen)
            }
            pendingAction = work
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay, execute: work)
        } else {
            stateViewModel.execute(actions: actions, screen: screen)
        }
    }
}

extension View {
    func fireProgressActions(
        actions: [VC.Action],
        transition: VC.Transition,
        value: Double
    ) -> some View {
        modifier(
            AdaptyUIProgressActionsModifier(
                actions: actions,
                transition: transition,
                value: value
            )
        )
    }
}

#endif

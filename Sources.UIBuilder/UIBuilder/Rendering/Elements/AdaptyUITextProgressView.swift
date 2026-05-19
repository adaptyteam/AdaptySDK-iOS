//
//  AdaptyUITextProgressView.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 20.04.2026.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUITextProgressView: View {
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject
    private var customTagResolverViewModel: AdaptyUITagResolverViewModel

    private let progress: VC.TextProgress

    init(_ progress: VC.TextProgress) {
        self.progress = progress
    }

    @State private var animatedValue: Double?
    @State private var pendingAction: DispatchWorkItem?

    var body: some View {
        let targetValue = stateViewModel.getValue(
            progress.value,
            defaultValue: 0.0,
            screen: screen
        )
        let displayValue = animatedValue ?? targetValue

        Color.clear
            .modifier(
                AnimatedProgressTextModifier(
                    value: displayValue,
                    progress: progress,
                    assetsCache: assetsViewModel.cache,
                    stateViewModel: stateViewModel,
                    customTagResolver: customTagResolverViewModel,
                    colorScheme: colorScheme,
                    screen: screen
                )
            )
            .onAppear {
                animatedValue = targetValue
            }
            .onChange(of: targetValue) { newValue in
                withAnimation(swiftUIAnimation) {
                    animatedValue = newValue
                }
                fireActionsWhenTransitionEnds()
            }
            .onDisappear {
                pendingAction?.cancel()
                pendingAction = nil
            }
    }

    private var swiftUIAnimation: Animation {
        progress.transition.interpolator.createAnimation(
            duration: progress.transition.duration
        )
    }

    private func fireActionsWhenTransitionEnds() {
        pendingAction?.cancel()
        pendingAction = nil
        guard !progress.actions.isEmpty else { return }
        let totalDelay = progress.transition.startDelay + progress.transition.duration
        let actions = progress.actions
        let screen = screen
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

private struct AnimatedProgressTextModifier: ViewModifier, @preconcurrency Animatable {
    var value: Double

    let progress: VC.TextProgress
    let assetsCache: AdaptyUIAssetsCache
    let stateViewModel: AdaptyUIStateViewModel
    let customTagResolver: AdaptyUITagResolverViewModel
    let colorScheme: ColorScheme
    let screen: VS.ScreenInstance

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    @MainActor
    func body(content: Content) -> some View {
        let currentValue = value
        let richText = progress.format.item(byValue: currentValue)
        return richText.convertToSwiftUIText(
            defaultAttributes: progress.format.textAttributes,
            assetsCache: assetsCache,
            stateViewModel: stateViewModel,
            tagValues: nil,
            internalTagResolver: { tag in
                tag == "PERCENT" ? currentValue : nil
            },
            customTagResolver: customTagResolver,
            productInfo: nil,
            colorScheme: colorScheme,
            screen: screen
        )
    }
}

private struct TextProgressTagResolver: AdaptyUITagResolver {
    let value: Double
    let fallback: AdaptyUITagResolver

    private var formattedValue: String {
        if value == value.rounded() {
            String(format: "%.0f", value)
        } else {
            String(value)
        }
    }

    func replacement(for tag: String) -> String? {
        if let result = fallback.replacement(for: tag) {
            return result
        }
        return formattedValue
    }
}

#endif

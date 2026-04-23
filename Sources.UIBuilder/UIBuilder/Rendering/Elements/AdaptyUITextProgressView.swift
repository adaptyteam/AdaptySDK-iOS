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

    @State private var animatedValue: Double = 0.0

    var body: some View {
        let richText = progress.format.item(byValue: animatedValue)
        let targetValue = stateViewModel.getValue(
            progress.value,
            defaultValue: 0.0,
            screen: screen
        )

        richText
            .convertToSwiftUIText(
                defaultAttributes: progress.format.textAttributes,
                assetsCache: assetsViewModel.cache,
                stateViewModel: stateViewModel,
                tagValues: nil,
                internalTagResolver: { value in
                    switch value {
                    case "PERCENT":
                        return targetValue
                    default:
                        return nil
                    }
                },
                customTagResolver: customTagResolverViewModel,
                productInfo: nil,
                colorScheme: colorScheme,
                screen: screen
            )
            .animation(swiftUIAnimation, value: animatedValue)
            .onAppear {
                animatedValue = targetValue
            }
            .onChange(of: targetValue) { newValue in
                animatedValue = newValue
                fireActionsWhenTransitionEnds()
            }
    }

    private var swiftUIAnimation: Animation {
        progress.transition.interpolator.createAnimation(
            duration: progress.transition.duration
        )
    }

    private func fireActionsWhenTransitionEnds() {
        guard !progress.actions.isEmpty else { return }
        let totalDelay = progress.transition.startDelay + progress.transition.duration
        let actions = progress.actions
        let screen = screen
        if totalDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) { [weak stateViewModel] in
                stateViewModel?.execute(actions: actions, screen: screen)
            }
        } else {
            stateViewModel.execute(actions: actions, screen: screen)
        }
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

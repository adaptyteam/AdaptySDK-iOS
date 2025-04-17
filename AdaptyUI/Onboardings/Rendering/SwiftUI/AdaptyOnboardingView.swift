//
//  OnboardingSplashView.swift
//
//
//  Created by Aleksey Goncharov on 09.08.2024.
//

import SwiftUI

@MainActor
public struct AdaptyOnboardingView<Placeholder: View>: View {
    private let configuration: AdaptyUI.OnboardingConfiguration

    private let placeholderViewBuilder: () -> Placeholder
    private let onCloseAction: (OnboardingsCloseAction) -> Void
    private let onOpenPaywallAction: ((OnboardingsOpenPaywallAction) -> Void)?
    private let onCustomAction: ((OnboardingsCustomAction) -> Void)?
    private let onStateUpdatedAction: ((OnboardingsStateUpdatedAction) -> Void)?
    private let onAnalyticsEvent: ((OnboardingsAnalyticsEvent) -> Void)?
    private let onError: (Error) -> Void

    @State private var isLoading = true

    public init(
        configuration: AdaptyUI.OnboardingConfiguration,
        placeholder: @escaping () -> Placeholder,
        onCloseAction: @escaping (OnboardingsCloseAction) -> Void,
        onOpenPaywallAction: ((OnboardingsOpenPaywallAction) -> Void)? = nil,
        onCustomAction: ((OnboardingsCustomAction) -> Void)? = nil,
        onStateUpdatedAction: ((OnboardingsStateUpdatedAction) -> Void)? = nil,
        onAnalyticsEvent: ((OnboardingsAnalyticsEvent) -> Void)? = nil,
        onError: @escaping (Error) -> Void
    ) {
        self.configuration = configuration
        self.placeholderViewBuilder = placeholder
        self.onCloseAction = onCloseAction
        self.onOpenPaywallAction = onOpenPaywallAction
        self.onCustomAction = onCustomAction
        self.onStateUpdatedAction = onStateUpdatedAction
        self.onAnalyticsEvent = onAnalyticsEvent
        self.onError = onError
    }

    @ViewBuilder
    private var zstackBody: some View {
        ZStack {
            AdaptyOnboardingView_Internal(
                configuration: configuration,
                onFinishLoading: { _ in
                    withAnimation {
                        isLoading = false
                    }
                },
                onCloseAction: onCloseAction,
                onOpenPaywallAction: onOpenPaywallAction,
                onCustomAction: onCustomAction,
                onStateUpdatedAction: onStateUpdatedAction,
                onAnalyticsEvent: onAnalyticsEvent,
                onError: onError
            )
            .zIndex(0)

            if isLoading {
                placeholderViewBuilder()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }

    public var body: some View {
        if #available(iOS 14.0, *) {
            zstackBody
                .ignoresSafeArea()
        } else {
            zstackBody
                .edgesIgnoringSafeArea(.all)
        }
    }
}

//
//  OnboardingSplashView.swift
//
//
//  Created by Aleksey Goncharov on 09.08.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public struct AdaptyOnboardingView<Placeholder: View>: View {
    private let configuration: AdaptyUI.OnboardingConfiguration

    private let placeholderViewBuilder: () -> Placeholder
    private let onFinishLoading: ((OnboardingsDidFinishLoadingAction) -> Void)?
    private let onCloseAction: (AdaptyOnboardingsCloseAction) -> Void
    private let onOpenPaywallAction: ((AdaptyOnboardingsOpenPaywallAction) -> Void)?
    private let onCustomAction: ((AdaptyOnboardingsCustomAction) -> Void)?
    private let onStateUpdatedAction: ((AdaptyOnboardingsStateUpdatedAction) -> Void)?
    private let onAnalyticsEvent: ((AdaptyOnboardingsAnalyticsEvent) -> Void)?
    private let onError: (Error) -> Void

    @State private var isLoading = true

    public init(
        configuration: AdaptyUI.OnboardingConfiguration,
        placeholder: @escaping () -> Placeholder,
        onFinishLoading: ((OnboardingsDidFinishLoadingAction) -> Void)? = nil,
        onCloseAction: @escaping (AdaptyOnboardingsCloseAction) -> Void,
        onOpenPaywallAction: ((AdaptyOnboardingsOpenPaywallAction) -> Void)? = nil,
        onCustomAction: ((AdaptyOnboardingsCustomAction) -> Void)? = nil,
        onStateUpdatedAction: ((AdaptyOnboardingsStateUpdatedAction) -> Void)? = nil,
        onAnalyticsEvent: ((AdaptyOnboardingsAnalyticsEvent) -> Void)? = nil,
        onError: @escaping (Error) -> Void
    ) {
        self.configuration = configuration
        self.placeholderViewBuilder = placeholder
        self.onFinishLoading = onFinishLoading
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
                onFinishLoading: { action in
                    onFinishLoading?(action)

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
            .onAppear {
                configuration.viewModel.viewDidAppear()
            }
            .onDisappear {
                configuration.viewModel.viewDidDisappear()
            }

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

#endif

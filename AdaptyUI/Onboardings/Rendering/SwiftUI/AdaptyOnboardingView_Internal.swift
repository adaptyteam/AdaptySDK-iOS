//
//  AdaptyOnboardingView_Internal.swift
//
//
//  Created by Aleksey Goncharov on 09.08.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyOnboardingView_Internal: UIViewRepresentable {
    typealias UIViewType = AdaptyOnboardingUIView

    private let delegate: AdaptyOnboardingViewDelegate
    private let configuration: AdaptyUI.OnboardingConfiguration
    private let onFinishLoading: (OnboardingsDidFinishLoadingAction) -> Void

    init(
        configuration: AdaptyUI.OnboardingConfiguration,
        onFinishLoading: @escaping (OnboardingsDidFinishLoadingAction) -> Void,
        onCloseAction: @escaping (AdaptyOnboardingsCloseAction) -> Void,
        onOpenPaywallAction: ((AdaptyOnboardingsOpenPaywallAction) -> Void)?,
        onCustomAction: ((AdaptyOnboardingsCustomAction) -> Void)?,
        onStateUpdatedAction: ((AdaptyOnboardingsStateUpdatedAction) -> Void)?,
        onAnalyticsEvent: ((AdaptyOnboardingsAnalyticsEvent) -> Void)?,
        onError: @escaping (AdaptyUIError) -> Void
    ) {
        self.configuration = configuration
        self.onFinishLoading = onFinishLoading
        self.delegate = OnboardingDelegateImpl(
            onFinishLoading: onFinishLoading,
            onCloseAction: onCloseAction,
            onOpenPaywallAction: onOpenPaywallAction,
            onCustomAction: onCustomAction,
            onStateUpdatedAction: onStateUpdatedAction,
            onAnalyticsEvent: onAnalyticsEvent,
            onError: onError
        )
    }

    func makeUIView(context: Context) -> AdaptyOnboardingUIView {
        let onboardingView = AdaptyOnboardingUIView(configuration: configuration)
        
        onboardingView.configure(delegate: delegate)
        onboardingView.layoutWebViewAndPlaceholder()
        
        return onboardingView
    }

    func updateUIView(_ uiView: AdaptyOnboardingUIView, context: Context) {
        uiView.delegate = delegate
    }
}

#endif

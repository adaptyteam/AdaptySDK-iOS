//
//  AdaptyOnboardingView_Internal.swift
//
//
//  Created by Aleksey Goncharov on 09.08.2024.
//

import Adapty
import SwiftUI

@MainActor
struct AdaptyOnboardingView_Internal: UIViewControllerRepresentable {
    private let delegate: AdaptyOnboardingControllerDelegate
    private let configuration: AdaptyUI.OnboardingConfiguration
    private let onFinishLoading: (OnboardingsDidFinishLoadingAction) -> Void

    init(
        configuration: AdaptyUI.OnboardingConfiguration,
        onFinishLoading: @escaping (OnboardingsDidFinishLoadingAction) -> Void,
        onCloseAction: @escaping (OnboardingsCloseAction) -> Void,
        onOpenPaywallAction: ((OnboardingsOpenPaywallAction) -> Void)?,
        onCustomAction: ((OnboardingsCustomAction) -> Void)?,
        onStateUpdatedAction: ((OnboardingsStateUpdatedAction) -> Void)?,
        onAnalyticsEvent: ((OnboardingsAnalyticsEvent) -> Void)?,
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

    public func makeUIViewController(context: Context) -> some UIViewController {
        AdaptyOnboardingController(
            configuration: configuration,
            delegate: delegate
        )
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        (uiViewController as? AdaptyOnboardingController)?.delegate = delegate
    }
}

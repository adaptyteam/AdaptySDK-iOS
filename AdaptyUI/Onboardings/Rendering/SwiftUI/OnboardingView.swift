//
//  OnboardingView.swift
//
//
//  Created by Aleksey Goncharov on 09.08.2024.
//

import SwiftUI

@MainActor
struct OnboardingView: UIViewControllerRepresentable {
    private let delegate: OnboardingDelegate
    private let url: URL
    private let onFinishLoading: (OnboardingsDidFinishLoadingAction) -> Void

    init(
        url: URL,
        onFinishLoading: @escaping (OnboardingsDidFinishLoadingAction) -> Void,
        onCloseAction: @escaping (OnboardingsCloseAction) -> Void,
        onOpenPaywallAction: ((OnboardingsOpenPaywallAction) -> Void)?,
        onCustomAction: ((OnboardingsCustomAction) -> Void)?,
        onStateUpdatedAction: ((OnboardingsStateUpdatedAction) -> Void)?,
        onAnalyticsEvent: ((OnboardingsAnalyticsEvent) -> Void)?,
        onError: @escaping (OnboardingsError) -> Void
    ) {
        self.url = url
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
        OnboardingController(
            url: url,
            delegate: delegate
        )
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        (uiViewController as? OnboardingController)?.delegate = delegate
    }
}

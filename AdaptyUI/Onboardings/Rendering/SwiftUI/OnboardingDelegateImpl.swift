//
//  OnboardingDelegateImpl.swift
//
//
//  Created by Aleksey Goncharov on 06.08.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
final class OnboardingDelegateImpl: AdaptyOnboardingViewDelegate {
    private let onFinishLoading: (OnboardingsDidFinishLoadingAction) -> Void
    private let onCloseAction: (AdaptyOnboardingsCloseAction) -> Void
    private let onOpenPaywallAction: ((AdaptyOnboardingsOpenPaywallAction) -> Void)?
    private let onCustomAction: ((AdaptyOnboardingsCustomAction) -> Void)?
    private let onStateUpdatedAction: ((AdaptyOnboardingsStateUpdatedAction) -> Void)?
    private let onAnalyticsEvent: ((AdaptyOnboardingsAnalyticsEvent) -> Void)?
    private let onError: (AdaptyUIError) -> Void

    init(
        onFinishLoading: @escaping (OnboardingsDidFinishLoadingAction) -> Void,
        onCloseAction: @escaping (AdaptyOnboardingsCloseAction) -> Void,
        onOpenPaywallAction: ((AdaptyOnboardingsOpenPaywallAction) -> Void)?,
        onCustomAction: ((AdaptyOnboardingsCustomAction) -> Void)?,
        onStateUpdatedAction: ((AdaptyOnboardingsStateUpdatedAction) -> Void)?,
        onAnalyticsEvent: ((AdaptyOnboardingsAnalyticsEvent) -> Void)?,
        onError: @escaping (AdaptyUIError) -> Void
    ) {
        self.onFinishLoading = onFinishLoading
        self.onCloseAction = onCloseAction
        self.onOpenPaywallAction = onOpenPaywallAction
        self.onCustomAction = onCustomAction
        self.onStateUpdatedAction = onStateUpdatedAction
        self.onAnalyticsEvent = onAnalyticsEvent
        self.onError = onError
    }

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    ) {
        onFinishLoading(action)
    }

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onCloseAction action: AdaptyOnboardingsCloseAction
    ) {
        onCloseAction(action)
    }

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onPaywallAction action: AdaptyOnboardingsOpenPaywallAction
    ) {
        if let onOpenPaywallAction {
            onOpenPaywallAction(action)
        } else {
            Log.onboardings.warn("OnboardingView: Not implimented callback 'onOpenPaywallAction'")
        }
    }

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onCustomAction action: AdaptyOnboardingsCustomAction
    ) {
        if let onCustomAction {
            onCustomAction(action)
        } else {
            Log.onboardings.warn("OnboardingView: Not implimented callback 'onCustomAction'")
        }
    }

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction
    ) {
        if let onStateUpdatedAction {
            onStateUpdatedAction(action)
        } else {
            Log.onboardings.warn("OnboardingView: Not implimented callback 'onStateUpdatedAction'")
        }
    }

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent
    ) {
        onAnalyticsEvent?(event)
    }

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        didFailWithError error: AdaptyUIError
    ) {
        onError(error)
    }

    func onboardingsViewLoadingPlaceholder(
        _ view: AdaptyOnboardingUIView
    ) -> UIView? {
        nil
    }
}

#endif

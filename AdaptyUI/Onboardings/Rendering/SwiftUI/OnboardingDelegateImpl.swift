//
//  OnboardingDelegateImpl.swift
//
//
//  Created by Aleksey Goncharov on 06.08.2024.
//

import SwiftUI
import Adapty

final class OnboardingDelegateImpl: NSObject, AdaptyOnboardingControllerDelegate {
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

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    ) {
        onFinishLoading(action)
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onCloseAction action: AdaptyOnboardingsCloseAction
    ) {
        onCloseAction(action)
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onPaywallAction action: AdaptyOnboardingsOpenPaywallAction
    ) {
        if let onOpenPaywallAction {
            onOpenPaywallAction(action)
        } else {
            Log.onboardings.warn("OnboardingView: Not implimented callback 'onOpenPaywallAction'")
        }
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onCustomAction action: AdaptyOnboardingsCustomAction
    ) {
        if let onCustomAction {
            onCustomAction(action)
        } else {
            Log.onboardings.warn("OnboardingView: Not implimented callback 'onCustomAction'")
        }
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction
    ) {
        if let onStateUpdatedAction {
            onStateUpdatedAction(action)
        } else {
            Log.onboardings.warn("OnboardingView: Not implimented callback 'onStateUpdatedAction'")
        }
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent
    ) {
        onAnalyticsEvent?(event)
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        didFailWithError error: AdaptyUIError
    ) {
        onError(error)
    }
}

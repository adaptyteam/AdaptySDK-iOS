//
//  OnboardingDelegateImpl.swift
//
//
//  Created by Aleksey Goncharov on 06.08.2024.
//

import SwiftUI
import Adapty

final class OnboardingDelegateImpl: NSObject, OnboardingDelegate {
    private let onFinishLoading: (OnboardingsDidFinishLoadingAction) -> Void
    private let onCloseAction: (OnboardingsCloseAction) -> Void
    private let onOpenPaywallAction: ((OnboardingsOpenPaywallAction) -> Void)?
    private let onCustomAction: ((OnboardingsCustomAction) -> Void)?
    private let onStateUpdatedAction: ((OnboardingsStateUpdatedAction) -> Void)?
    private let onAnalyticsEvent: ((OnboardingsAnalyticsEvent) -> Void)?
    private let onError: (AdaptyError) -> Void

    init(
        onFinishLoading: @escaping (OnboardingsDidFinishLoadingAction) -> Void,
        onCloseAction: @escaping (OnboardingsCloseAction) -> Void,
        onOpenPaywallAction: ((OnboardingsOpenPaywallAction) -> Void)?,
        onCustomAction: ((OnboardingsCustomAction) -> Void)?,
        onStateUpdatedAction: ((OnboardingsStateUpdatedAction) -> Void)?,
        onAnalyticsEvent: ((OnboardingsAnalyticsEvent) -> Void)?,
        onError: @escaping (AdaptyError) -> Void
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
        _ controller: UIViewController,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    ) {
        onFinishLoading(action)
    }

    func onboardingController(
        _ controller: UIViewController,
        onCloseAction action: OnboardingsCloseAction
    ) {
        onCloseAction(action)
    }

    func onboardingController(
        _ controller: UIViewController,
        onPaywallAction action: OnboardingsOpenPaywallAction
    ) {
        if let onOpenPaywallAction {
            onOpenPaywallAction(action)
        } else {
            Log.onboardings.warn("OnboardingView: Not implimented callback 'onOpenPaywallAction'")
        }
    }

    func onboardingController(
        _ controller: UIViewController,
        onCustomAction action: OnboardingsCustomAction
    ) {
        if let onCustomAction {
            onCustomAction(action)
        } else {
            Log.onboardings.warn("OnboardingView: Not implimented callback 'onCustomAction'")
        }
    }

    func onboardingController(
        _ controller: UIViewController,
        onStateUpdatedAction action: OnboardingsStateUpdatedAction
    ) {
        if let onStateUpdatedAction {
            onStateUpdatedAction(action)
        } else {
            Log.onboardings.warn("OnboardingView: Not implimented callback 'onStateUpdatedAction'")
        }
    }

    func onboardingController(
        _ controller: UIViewController,
        onAnalyticsEvent event: OnboardingsAnalyticsEvent
    ) {
        onAnalyticsEvent?(event)
    }

    func onboardingController(
        _ controller: UIViewController,
        didFailWithError error: AdaptyError
    ) {
        onError(error)
    }
}

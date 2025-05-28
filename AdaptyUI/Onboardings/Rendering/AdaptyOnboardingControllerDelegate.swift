//
//  AdaptyOnboardingController.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

#if canImport(UIKit)

import Adapty
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package protocol AdaptyOnboardingViewDelegate: AnyObject {
    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    )

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onCloseAction action: AdaptyOnboardingsCloseAction
    )

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onPaywallAction action: AdaptyOnboardingsOpenPaywallAction
    )

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onCustomAction action: AdaptyOnboardingsCustomAction
    )

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction
    )

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent
    )

    func onboardingView(
        _ view: AdaptyOnboardingUIView,
        didFailWithError error: AdaptyUIError
    )

    func onboardingsViewLoadingPlaceholder(
        _ view: AdaptyOnboardingUIView
    ) -> UIView?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyOnboardingViewDelegate {
    func apply(message: AdaptyOnboardingsMessage, from view: AdaptyOnboardingUIView) {
        switch message {
        case let .close(action):
            onboardingView(view, onCloseAction: action)
        case let .custom(action):
            onboardingView(view, onCustomAction: action)
        case let .openPaywall(action):
            onboardingView(view, onPaywallAction: action)
        case let .stateUpdated(action):
            onboardingView(view, onStateUpdatedAction: action)
        case let .analytics(event):
            onboardingView(view, onAnalyticsEvent: event)
        case let .didFinishLoading(action):
            onboardingView(view, didFinishLoading: action)
        }
    }

    func apply(error: AdaptyUIError, from view: AdaptyOnboardingUIView) {
        onboardingView(view, didFailWithError: error)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public protocol AdaptyOnboardingControllerDelegate: AnyObject {
    func onboardingController(
        _ controller: AdaptyOnboardingController,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    )

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onCloseAction action: AdaptyOnboardingsCloseAction
    )

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onPaywallAction action: AdaptyOnboardingsOpenPaywallAction
    )

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onCustomAction action: AdaptyOnboardingsCustomAction
    )

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction
    )

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent
    )

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        didFailWithError error: AdaptyUIError
    )

    func onboardingsControllerLoadingPlaceholder(
        _ controller: AdaptyOnboardingController
    ) -> UIView?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyOnboardingControllerDelegate {
    func onboardingController(
        _ controller: UIViewController,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    ) {
        Log.onboardings.warn("Not implemented method 'onboardingController(didFinishLoading:)' of OnboardingDelegate ")
    }
    
    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onCloseAction action: AdaptyOnboardingsCloseAction
    ) {
        controller.dismiss(animated: true)
    }

    func onboardingController(
        _ controller: UIViewController,
        onPaywallAction action: AdaptyOnboardingsOpenPaywallAction
    ) {
        Log.onboardings.warn("Not implemented method 'onboardingController(openPaywallAction:)' of OnboardingDelegate ")
    }

    func onboardingController(
        _ controller: UIViewController,
        onCustomAction action: AdaptyOnboardingsCustomAction
    ) {
        Log.onboardings.warn("Not implemented method 'onboardingController(onCustomAction:)' of OnboardingDelegate ")
    }

    func onboardingController(
        _ controller: UIViewController,
        onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction
    ) {
        Log.onboardings.warn("Not implemented method 'onboardingController(onStateUpdatedAction:)' of OnboardingDelegate ")
    }

    func onboardingController(
        _ controller: UIViewController,
        onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent
    ) {
        Log.onboardings.warn("Not implemented method 'onboardingController(onAnalyticsEvent:)' of OnboardingDelegate ")
    }

    func onboardingsControllerLoadingPlaceholder(
        _ controller: AdaptyOnboardingController
    ) -> UIView? {
        AdaptyOnboardingPlacehoderView(frame: .zero)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyOnboardingControllerDelegate {
    func apply(message: AdaptyOnboardingsMessage, from controller: AdaptyOnboardingController) {
        switch message {
        case let .close(action):
            onboardingController(controller, onCloseAction: action)
        case let .custom(action):
            onboardingController(controller, onCustomAction: action)
        case let .openPaywall(action):
            onboardingController(controller, onPaywallAction: action)
        case let .stateUpdated(action):
            onboardingController(controller, onStateUpdatedAction: action)
        case let .analytics(event):
            onboardingController(controller, onAnalyticsEvent: event)
        case let .didFinishLoading(action):
            onboardingController(controller, didFinishLoading: action)
        }
    }

    func apply(error: AdaptyUIError, from controller: AdaptyOnboardingController) {
        onboardingController(controller, didFailWithError: error)
    }
}

#endif

//
//  AdaptyOnboardingController.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import Adapty
import UIKit

@MainActor
public protocol AdaptyOnboardingControllerDelegate: NSObjectProtocol {
    func onboardingController(_ controller: AdaptyOnboardingController, didFinishLoading action: OnboardingsDidFinishLoadingAction)
    func onboardingController(_ controller: AdaptyOnboardingController, onCloseAction action: AdaptyOnboardingsCloseAction)
    func onboardingController(_ controller: AdaptyOnboardingController, onPaywallAction action: AdaptyOnboardingsOpenPaywallAction)
    func onboardingController(_ controller: AdaptyOnboardingController, onCustomAction action: AdaptyOnboardingsCustomAction)
    func onboardingController(_ controller: AdaptyOnboardingController, onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction)
    func onboardingController(_ controller: AdaptyOnboardingController, onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent)
    func onboardingController(_ controller: AdaptyOnboardingController, didFailWithError error: AdaptyUIError)
}

public protocol AdaptyOnboardingPlaceholderDelegate: NSObjectProtocol {
    func onboardingsControllerPlaceholderController() -> UIViewController?
}

public extension AdaptyOnboardingControllerDelegate {
    func onboardingController(_ controller: UIViewController, didFinishLoading action: OnboardingsDidFinishLoadingAction) {
        Log.onboardings.warn("Not implemented method 'onboardingController(didFinishLoading:)' of OnboardingDelegate ")
    }

    func onboardingController(_ controller: UIViewController, onPaywallAction action: AdaptyOnboardingsOpenPaywallAction) {
        Log.onboardings.warn("Not implemented method 'onboardingController(openPaywallAction:)' of OnboardingDelegate ")
    }

    func onboardingController(_ controller: UIViewController, onCustomAction action: AdaptyOnboardingsCustomAction) {
        Log.onboardings.warn("Not implemented method 'onboardingController(onCustomAction:)' of OnboardingDelegate ")
    }

    func onboardingController(_ controller: UIViewController, onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction) {
        Log.onboardings.warn("Not implemented method 'onboardingController(onStateUpdatedAction:)' of OnboardingDelegate ")
    }

    func onboardingController(_ controller: UIViewController, onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent) {
        Log.onboardings.warn("Not implemented method 'onboardingController(onAnalyticsEvent:)' of OnboardingDelegate ")
    }
}

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

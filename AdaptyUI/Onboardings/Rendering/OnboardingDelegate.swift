//
//  OnboardingDelegate.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import UIKit

private let log = Log.Category(name: "OnboardingDelegate")

@MainActor
public protocol OnboardingDelegate: NSObjectProtocol {
    func onboardingController(_ controller: UIViewController, didFinishLoading action: OnboardingsDidFinishLoadingAction)
    func onboardingController(_ controller: UIViewController, onCloseAction action: OnboardingsCloseAction)
    func onboardingController(_ controller: UIViewController, onPaywallAction action: OnboardingsOpenPaywallAction)
    func onboardingController(_ controller: UIViewController, onCustomAction action: OnboardingsCustomAction)
    func onboardingController(_ controller: UIViewController, onStateUpdatedAction action: OnboardingsStateUpdatedAction)
    func onboardingController(_ controller: UIViewController, onAnalyticsEvent event: OnboardingsAnalyticsEvent)
    func onboardingController(_ controller: UIViewController, didFailWithError error: OnboardingsError)
}

public protocol OnboardingSplashDelegate: NSObjectProtocol {
    func onboardingsSplashViewController() -> UIViewController?
}

public extension OnboardingDelegate {
    func onboardingController(_ controller: UIViewController, didFinishLoading action: OnboardingsDidFinishLoadingAction) {
        log.warn("Not implemented method 'onboardingController(didFinishLoading:)' of OnboardingDelegate ")
    }

    func onboardingController(_ controller: UIViewController, onPaywallAction action: OnboardingsOpenPaywallAction) {
        log.warn("Not implemented method 'onboardingController(openPaywallAction:)' of OnboardingDelegate ")
    }

    func onboardingController(_ controller: UIViewController, onCustomAction action: OnboardingsCustomAction) {
        log.warn("Not implemented method 'onboardingController(onCustomAction:)' of OnboardingDelegate ")
    }

    func onboardingController(_ controller: UIViewController, onStateUpdatedAction action: OnboardingsStateUpdatedAction) {
        log.warn("Not implemented method 'onboardingController(onStateUpdatedAction:)' of OnboardingDelegate ")
    }

    func onboardingController(_ controller: UIViewController, onAnalyticsEvent event: OnboardingsAnalyticsEvent) {
        log.warn("Not implemented method 'onboardingController(onAnalyticsEvent:)' of OnboardingDelegate ")
    }
}

extension OnboardingDelegate {
    func apply(message: OnboardingsMessage, from controller: UIViewController) {
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

    func apply(error: OnboardingsError, from controller: UIViewController) {
        onboardingController(controller, didFailWithError: error)
    }
}

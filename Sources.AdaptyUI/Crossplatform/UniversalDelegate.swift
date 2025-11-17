//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 14.11.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@MainActor
extension AdaptyUI {
    public static var universalDelegate: (AdaptyPaywallControllerDelegate & AdaptyOnboardingControllerDelegate)?

    package static func paywallControllerWithUniversalDelegate(
        _ paywallConfiguration: PaywallConfiguration,
        showDebugOverlay: Bool = false
    ) throws -> AdaptyPaywallController {
        guard AdaptyUI.isActivated else {
            let err = AdaptyUIError.adaptyNotActivated
            Log.ui.error("AdaptyUI paywallController(for:) error: \(err)")
            throw err
        }

        guard let delegate = AdaptyUI.universalDelegate else {
            Log.ui.error("AdaptyUI delegateIsNotRegestired")
            throw AdaptyError(AdaptyUI.PluginError.delegateIsNotRegestired)
        }

        return AdaptyPaywallController(
            paywallConfiguration: paywallConfiguration,
            delegate: delegate,
            showDebugOverlay: showDebugOverlay
        )
    }
}

@MainActor
extension AdaptyUI {
    package static func onboardingControllerWithUniversalDelegate(
        _ onboardingConfiguration: OnboardingConfiguration
    ) throws -> AdaptyOnboardingController {
        guard AdaptyUI.isActivated else {
            let err = AdaptyUIError.adaptyNotActivated
            Log.ui.error("AdaptyUI onboardingConfiguration(for:) error: \(err)")
            throw err
        }

        guard let delegate = AdaptyUI.universalDelegate else {
            Log.ui.error("AdaptyUI delegateIsNotRegestired")
            throw AdaptyError(AdaptyUI.PluginError.delegateIsNotRegestired)
        }

        return AdaptyOnboardingController(
            configuration: onboardingConfiguration,
            delegate: delegate,
            statusBarStyle: .lightContent
        )
    }
}

#endif

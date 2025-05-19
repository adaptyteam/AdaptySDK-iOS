//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 14.11.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

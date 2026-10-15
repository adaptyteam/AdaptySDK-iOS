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
    /// Receives the events of every view created through the plugin. Flow views
    /// need it to conform to ``AdaptyFlowControllerDelegate`` as well.
    public static var universalDelegate: AdaptyOnboardingControllerDelegate?

    @available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
    package static func paywallControllerWithUniversalDelegate(
        _ paywallConfiguration: FlowConfiguration,
        showDebugOverlay: Bool = false
    ) throws -> AdaptyFlowController {
        guard AdaptyUI.isActivated else {
            let err = AdaptyUIError.adaptyNotActivated
            Log.ui.error("AdaptyUI paywallController(for:) error: \(err)")
            throw err
        }

        guard let universalDelegate = AdaptyUI.universalDelegate else {
            Log.ui.error("AdaptyUI delegateIsNotRegestired")
            throw AdaptyError(AdaptyUI.PluginError.delegateIsNotRegestired)
        }

        guard let delegate = universalDelegate as? AdaptyFlowControllerDelegate else {
            Log.ui.error("AdaptyUI universalDelegate does not conform to AdaptyFlowControllerDelegate, which flow views require")
            throw AdaptyError(AdaptyUI.PluginError.delegateIsNotRegestired)
        }

        return AdaptyFlowController(
            paywallConfiguration: paywallConfiguration,
            delegate: delegate,
            showDebugOverlay: showDebugOverlay
        )
    }
}

@MainActor
extension AdaptyUI {
    @available(*, deprecated, message: "Starting Adapty SDK 4.0.0, Onboarding Feature is deprecated. Please consider migrating to Flows")
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

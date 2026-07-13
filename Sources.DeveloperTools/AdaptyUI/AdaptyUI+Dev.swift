//
//  AdaptyUI.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksei Valiano on 24.09.2025.
//

#if canImport(UIKit)

import Adapty
import AdaptyUI

@MainActor
public extension AdaptyUI {
    static func dev_getOnboardingConfiguration(
        forOnboarding onboarding: AdaptyOnboarding,
        externalUrlsPresentation: AdaptyWebPresentation,
        inspectWebView: Bool
    ) throws -> OnboardingConfiguration {
        try AdaptyUI.getOnboardingConfiguration(
            forOnboarding: onboarding,
            externalUrlsPresentation: externalUrlsPresentation,
            inspectWebView: inspectWebView
        )
    }
}

#endif

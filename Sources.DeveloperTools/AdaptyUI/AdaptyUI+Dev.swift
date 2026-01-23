//
//  AdaptyUI.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksei Valiano on 24.09.2025.
//

#if canImport(UIKit)

import Adapty
import AdaptyUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

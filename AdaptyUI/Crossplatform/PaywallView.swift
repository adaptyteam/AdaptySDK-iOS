//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyUI {
    struct PaywallView: Sendable {
        package let id: String
        package let templateId: String
        package let placementId: String
        package let variationId: String
    }

    struct OnboardingView: Sendable {
        package let id: String
        package let placementId: String
        package let variationId: String
    }
}

#if canImport(UIKit)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyPaywallController {
    func toAdaptyUIView() -> AdaptyUI.PaywallView {
        AdaptyUI.PaywallView(
            id: id.uuidString,
            templateId: paywallConfiguration.paywallViewModel.viewConfiguration.templateId,
            placementId: paywallConfiguration.paywallViewModel.paywall.placementId,
            variationId: paywallConfiguration.paywallViewModel.paywall.variationId
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyOnboardingController {
    func toAdaptyUIView() -> AdaptyUI.OnboardingView {
        AdaptyUI.OnboardingView(
            id: id,
            placementId: onboarding.placement.id,
            variationId: onboarding.variationId
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension AdaptyOnboardingUIView {
    func toAdaptyUIView() -> AdaptyUI.OnboardingView {
        AdaptyUI.OnboardingView(
            id: id,
            placementId: onboarding.placement.id,
            variationId: onboarding.variationId
        )
    }
}

#endif

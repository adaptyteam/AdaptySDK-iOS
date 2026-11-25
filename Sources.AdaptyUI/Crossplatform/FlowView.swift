//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Foundation

public extension AdaptyUI {
    struct FlowView: Sendable {
        package let id: String
        package let placementId: String
        package let variationId: String
        /// The localization the view was built with: the one the localization
        /// strategy chose, or the flow's default localization when the flow has
        /// no localization with the chosen identifier.
        package let locale: String?

        package init(id: String, placementId: String, variationId: String, locale: String? = nil) {
            self.id = id
            self.placementId = placementId
            self.variationId = variationId
            self.locale = locale
        }
    }

    struct OnboardingView: Sendable {
        package let id: String
        package let placementId: String
        package let variationId: String
    }
}

#if canImport(UIKit)

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
package extension AdaptyFlowUIView {
    func toAdaptyUIView() -> AdaptyUI.FlowView {
        AdaptyUI.FlowView(
            id: id,
            placementId: configuration.flowPlacementId,
            variationId: configuration.flowVariationId,
            locale: configuration.locale
        )
    }
}

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
public extension AdaptyFlowController {
    func toAdaptyUIView() -> AdaptyUI.FlowView {
        AdaptyUI.FlowView(
            id: id,
            placementId: configuration.flowPlacementId,
            variationId: configuration.flowVariationId,
            locale: configuration.locale
        )
    }
}

@available(*, deprecated, message: "Starting Adapty SDK 4.0.0, Onboarding Feature is deprecated. Please consider migrating to Flows")
public extension AdaptyOnboardingController {
    func toAdaptyUIView() -> AdaptyUI.OnboardingView {
        AdaptyUI.OnboardingView(
            id: id,
            placementId: onboarding.placement.id,
            variationId: onboarding.variationId
        )
    }
}

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

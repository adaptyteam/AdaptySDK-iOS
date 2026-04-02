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

package extension AdaptyFlowUIView {
    func toAdaptyUIView() -> AdaptyUI.FlowView {
        AdaptyUI.FlowView(
            id: id,
            templateId: "// TODO: todo", // configuration.flowViewModel.viewConfiguration.deprecated_defaultScreen.templateId,
            placementId: configuration.paywallPlacementId,
            variationId: configuration.paywallVariationId
        )
    }
}

public extension AdaptyFlowController {
    func toAdaptyUIView() -> AdaptyUI.FlowView {
        AdaptyUI.FlowView(
            id: id,
            templateId: "// TODO: todo",
            placementId: configuration.paywallVariationId,
            variationId: configuration.paywallVariationId
        )
    }
}

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

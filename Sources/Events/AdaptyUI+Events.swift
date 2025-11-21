//
//  AdaptyUI+Events.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.10.2025.
//

package extension Adapty {
    nonisolated static func logShowPaywallViaAdaptyUI(_ paywall: AdaptyPaywall) async throws(AdaptyError) {
        try await trackEvent(
            .paywallShowed(.init(
                variationId: paywall.variationId,
                viewConfigurationId: paywall.viewConfiguration?.id
            ))
        )
    }

    nonisolated static func logShowOnboardingViaAdaptyUI(_ params: AdaptyUIOnboardingScreenShowedParameters) async throws(AdaptyError) {
        try await trackEvent(
            .onboardingScreenShowed(params)
        )
    }
}

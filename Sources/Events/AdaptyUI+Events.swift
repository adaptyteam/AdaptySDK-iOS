//
//  AdaptyUI+Events.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.10.2025.
//

package extension Adapty {
    nonisolated static func logFlowAnalyticsViaAdaptyUI(
        variationId: String,
        viewConfigurationId: String,
        params: AdaptyFlowAnalyticsPayload
    ) async throws(AdaptyError) {
        try await trackEvent(
            .flowAnalytics(
                .init(
                    variationId: variationId,
                    viewConfigurationId: viewConfigurationId,
                    payload: params
                )
            )
        )
    }

    nonisolated static func logShowOnboardingViaAdaptyUI(_ params: AdaptyUIOnboardingScreenShowedParameters) async throws(AdaptyError) {
        try await trackEvent(
            .onboardingScreenShowed(params)
        )
    }
}


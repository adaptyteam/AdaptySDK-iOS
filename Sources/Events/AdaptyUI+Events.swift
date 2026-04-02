//
//  AdaptyUI+Events.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.10.2025.
//

package extension Adapty {
    nonisolated static func logShowFlowViaAdaptyUI(_ flow: AdaptyFlow) async throws(AdaptyError) {
        try await trackEvent(
            .flowShowed(.init(
                variationId: flow.variationId,
                viewConfigurationId: flow.viewConfiguration?.id
            ))
        )
    }

    nonisolated static func logShowOnboardingViaAdaptyUI(_ params: AdaptyUIOnboardingScreenShowedParameters) async throws(AdaptyError) {
        try await trackEvent(
            .onboardingScreenShowed(params)
        )
    }
}

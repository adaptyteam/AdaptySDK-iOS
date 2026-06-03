//
//  AdaptyUI+Events.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.10.2025.
//

import Foundation

package extension Adapty {
    nonisolated static func logFlowAnalyticsViaAdaptyUI(
        variationId: String,
        sessionId: UUID?,
        flowVersionId: String,
        flowLayoutId: String,
        params: AdaptyFlowAnalyticsPayload
    ) async throws(AdaptyError) {
        try await trackEvent(
            .flowAnalytics(
                .init(
                    variationId: variationId,
                    sessionId: sessionId,
                    flowVersionId: flowVersionId,
                    flowLayoutId: flowLayoutId,
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


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
        sessionId: UUID,
        flowLayout: AdaptyFlow.Layout,
        params: AdaptyFlowAnalyticsPayload
    ) async throws(AdaptyError) {
        try await trackEvent(
            .flowAnalytics(
                .init(
                    variationId: variationId,
                    sessionId: sessionId,
                    flowVersionId: flowLayout.versionId,
                    flowLayoutId: flowLayout.id,
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

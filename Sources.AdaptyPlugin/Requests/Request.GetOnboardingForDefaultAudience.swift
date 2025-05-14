//
//  Request.GetOnboardingForDefaultAudience.swift
//  Adapty
//
//  Created by Aleksei Valiano on 14.05.2025.
//

import Adapty
import Foundation

extension Request {
    struct GetOnboardingForDefaultAudience: AdaptyPluginRequest {
        static let method = "get_onboarding_for_default_audience"

        let placementId: String
        let locale: String?
        let fetchPolicy: AdaptyPlacementFetchPolicy?

        enum CodingKeys: String, CodingKey {
            case placementId = "placement_id"
            case locale
            case fetchPolicy = "fetch_policy"
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(await Adapty.getOnboardingForDefaultAudience(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy ?? AdaptyPlacementFetchPolicy.default
            ))
        }
    }
}

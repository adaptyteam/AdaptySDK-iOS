//
//  Request.GetOnboarding.swift
//  Adapty
//
//  Created by Aleksei Valiano on 14.05.2025.
//


import Adapty
import Foundation

extension Request {
    struct GetOnboarding: AdaptyPluginRequest {
        static let method = "get_onboarding"

        let placementId: String
        let locale: String?
        let fetchPolicy: AdaptyPlacementFetchPolicy?
        let loadTimeout: TimeInterval?

        enum CodingKeys: String, CodingKey {
            case placementId = "placement_id"
            case locale
            case fetchPolicy = "fetch_policy"
            case loadTimeout = "load_timeout"
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(await Adapty.getOnboarding(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy ?? AdaptyPlacementFetchPolicy.default,
                loadTimeout: loadTimeout
            ))
        }
    }
}

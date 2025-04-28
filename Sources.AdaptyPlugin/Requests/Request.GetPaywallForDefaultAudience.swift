//
//  Request.GetPaywallForDefaultAudience.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 15.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetPaywallForDefaultAudience: AdaptyPluginRequest {
        static let method = "get_paywall_for_default_audience"

        let placementId: String
        let locale: String?
        let fetchPolicy: AdaptyPlacementFetchPolicy?

        enum CodingKeys: String, CodingKey {
            case placementId = "placement_id"
            case locale
            case fetchPolicy = "fetch_policy"
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(await Adapty.getPaywallForDefaultAudience(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy ?? AdaptyPlacementFetchPolicy.default
            ))
        }
    }
}

//
//  Request.GetPaywall.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetPaywall: AdaptyPluginRequest {
        static let method = "get_paywall"

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
            try .success(await Adapty.getPaywall(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy ?? AdaptyPlacementFetchPolicy.default,
                loadTimeout: loadTimeout
            ))
        }
    }
}

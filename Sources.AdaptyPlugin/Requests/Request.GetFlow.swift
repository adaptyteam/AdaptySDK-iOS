//
//  Request.GetFlow.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetFlow: AdaptyPluginRequest {
        static let method = "get_flow"

        let placementId: String
        let fetchPolicy: AdaptyPlacementFetchPolicy?
        let loadTimeout: TimeInterval?

        enum CodingKeys: String, CodingKey {
            case placementId = "placement_id"
            case fetchPolicy = "fetch_policy"
            case loadTimeout = "load_timeout"
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(await Adapty.getFlow(
                placementId: placementId,
                fetchPolicy: fetchPolicy ?? AdaptyPlacementFetchPolicy.default,
                loadTimeout: loadTimeout
            ))
        }
    }
}

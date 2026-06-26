//
//  Request.GetFlowForDefaultAudience.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 15.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetFlowForDefaultAudience: AdaptyPluginRequest {
        static let method = "get_flow_for_default_audience"

        let placementId: String
        let fetchPolicy: AdaptyPlacementFetchPolicy?

        enum CodingKeys: String, CodingKey {
            case placementId = "placement_id"
            case fetchPolicy = "fetch_policy"
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(await Adapty.getFlowForDefaultAudience(
                placementId: placementId,
                fetchPolicy: fetchPolicy ?? AdaptyPlacementFetchPolicy.default
            ))
        }
    }
}

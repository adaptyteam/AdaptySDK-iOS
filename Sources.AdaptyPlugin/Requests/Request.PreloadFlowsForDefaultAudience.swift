//
//  Request.PreloadFlowsForDefaultAudience.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 28.08.2026.
//

import Adapty
import Foundation

extension Request {
    struct PreloadFlowsForDefaultAudience: AdaptyPluginRequest {
        static let method = "preload_flows_for_default_audience"

        let placementIds: [String]

        enum CodingKeys: String, CodingKey {
            case placementIds = "placement_ids"
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.preloadFlowsForDefaultAudience(
                placementIds: placementIds
            )
            return .success()
        }
    }
}

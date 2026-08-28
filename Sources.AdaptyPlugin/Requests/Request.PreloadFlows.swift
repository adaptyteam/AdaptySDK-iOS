//
//  Request.PreloadFlows.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 28.08.2026.
//

import Adapty
import Foundation

extension Request {
    struct PreloadFlows: AdaptyPluginRequest {
        static let method = "preload_flows"

        let placementIds: [String]
        let loadTimeout: TimeInterval?

        enum CodingKeys: String, CodingKey {
            case placementIds = "placement_ids"
            case loadTimeout = "load_timeout"
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.preloadFlows(
                placementIds: placementIds,
                loadTimeout: loadTimeout
            )
            return .success()
        }
    }
}

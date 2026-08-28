//
//  Request.PreloadOnboardings.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 28.08.2026.
//

import Adapty
import Foundation

extension Request {
    struct PreloadOnboardings: AdaptyPluginRequest {
        static let method = "preload_onboardings"

        let placementIds: [String]
        let locale: String?
        let loadTimeout: TimeInterval?

        enum CodingKeys: String, CodingKey {
            case placementIds = "placement_ids"
            case locale
            case loadTimeout = "load_timeout"
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.preloadOnboardings(
                placementIds: placementIds,
                locale: locale,
                loadTimeout: loadTimeout
            )
            return .success()
        }
    }
}

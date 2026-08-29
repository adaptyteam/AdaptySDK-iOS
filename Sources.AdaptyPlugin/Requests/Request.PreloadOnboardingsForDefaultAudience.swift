//
//  Request.PreloadOnboardingsForDefaultAudience.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 28.08.2026.
//

import Adapty
import Foundation

extension Request {
    struct PreloadOnboardingsForDefaultAudience: AdaptyPluginRequest {
        static let method = "preload_onboardings_for_default_audience"

        let placementIds: [String]
        let locale: String?

        enum CodingKeys: String, CodingKey {
            case placementIds = "placement_ids"
            case locale
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.preloadOnboardingsForDefaultAudience(
                placementIds: placementIds,
                locale: locale
            )
            return .success()
        }
    }
}

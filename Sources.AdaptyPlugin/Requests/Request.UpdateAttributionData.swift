//
//  Request.UpdateAttributionData.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct UpdateAttributionData: AdaptyPluginRequest {
        static let method = "update_attribution_data"

        let attribution: String
        let source: String

        enum CodingKeys: String, CodingKey {
            case attribution
            case source
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.updateAttribution(attribution, source: source)
            return .success()
        }
    }
}

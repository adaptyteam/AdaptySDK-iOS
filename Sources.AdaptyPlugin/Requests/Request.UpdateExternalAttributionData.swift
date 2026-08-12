//
//  Request.UpdateExternalAttributionData.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct UpdateExternalAttributionData: AdaptyPluginRequest {
        static let method = "update_external_attribution_data"

        let attribution: String
        let provider: AdaptyExternalAttributionProvider

        enum CodingKeys: String, CodingKey {
            case attribution
            case provider
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.updateExternalAttribution(attribution, provider: provider)
            return .success()
        }
    }
}

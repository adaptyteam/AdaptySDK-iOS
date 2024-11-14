//
//  Request.UpdateAttribution.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct UpdateAttribution: AdaptyPluginRequest {
        static let method = "update_attribution"

        let attribution: [String: any Sendable]
        let source: AdaptyAttributionSource
        let networkUserId: String?

        enum CodingKeys: String, CodingKey {
            case attribution
            case source
            case networkUserId = "network_user_id"
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard let data = try container
                .decode(String.self, forKey: .attribution)
                .data(using: .utf8),
                let attribution = try JSONSerialization.jsonObject(with: data) as? [String: any Sendable]
            else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: container.codingPath + [CodingKeys.attribution],
                    debugDescription: "attribution must be a valid JSON string"
                ))
            }

            self.attribution = attribution
            self.source = try container.decode(AdaptyAttributionSource.self, forKey: .source)
            self.networkUserId = try container.decodeIfPresent(String.self, forKey: .networkUserId)
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.updateAttribution(attribution, source: source, networkUserId: networkUserId)
            return .success()
        }
    }
}

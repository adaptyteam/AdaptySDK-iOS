//
//  Request.SetIntegrationIdentifier.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 27.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct SetIntegrationIdentifier: AdaptyPluginRequest {
        static let method = "set_integration_identifiers"

        let keyValues: [String: String]

        enum CodingKeys: String, CodingKey {
            case keyValues = "key_values"
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.setIntegrationIdentifiers(keyValues)
            return .success()
        }
    }
}

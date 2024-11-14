//
//  Request.Identify.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct Identify: AdaptyPluginRequest {
        static let method = "identify"

        let customerUserId: String

        enum CodingKeys: String, CodingKey {
            case customerUserId = "customer_user_id"
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.identify(customerUserId)
            return .success()
        }
    }
}

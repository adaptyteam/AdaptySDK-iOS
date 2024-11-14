//
//  Request.SetVariationId.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct SetVariationId: AdaptyPluginRequest {
        static let method = "set_variation_id"

        let variationId: String
        let transactionId: String

        enum CodingKeys: String, CodingKey {
            case variationId = "variation_id"
            case transactionId = "transaction_id"
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.setVariationId(variationId, forTransactionId: transactionId)
            return .success()
        }
    }
}

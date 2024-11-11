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
        static let method = Method.setVariationId

        let variationId: String
        let transactionId: String

        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                variationId: jsonDictionary.value(String.self, forKey: CodingKeys.variationId),
                transactionId: jsonDictionary.value(String.self, forKey: CodingKeys.transactionId)
            )
        }

        init(variationId: String, transactionId: String) {
            self.variationId = variationId
            self.transactionId = transactionId
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.setVariationId(variationId, forTransactionId: transactionId)
            return .success()
        }
    }
}

private enum CodingKeys: String, CodingKey {
    case variationId = "variation_id"
    case transactionId = "transaction_id"
}

public extension AdaptyPlugin {
    @objc static func setVariationId(
        variationId: String,
        transactionId: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        withCompletion(completion) {
            await Request.SetVariationId.execute {
                Request.SetVariationId(
                    variationId: variationId,
                    transactionId: transactionId
                )
            }
        }
    }
}

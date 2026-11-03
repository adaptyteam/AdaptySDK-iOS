//
//  Request.ReportTransaction.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct ReportTransaction: AdaptyPluginRequest {
        static let method = "report_transaction"

        let variationId: String?
        let transactionId: String
        let jwsTransaction: String?

        enum CodingKeys: String, CodingKey {
            case variationId = "variation_id"
            case transactionId = "transaction_id"
            case jwsTransaction = "apple_jws_transaction"
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.reportTransaction(transactionId, jwsTransaction: jwsTransaction, withVariationId: variationId)
            return .success()
        }
    }
}

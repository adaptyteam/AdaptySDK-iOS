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

        enum CodingKeys: String, CodingKey {
            case variationId = "variation_id"
            case transactionId = "transaction_id"
        }

        func execute() async throws -> AdaptyJsonData {
            let profile = try await Adapty.reportTransaction(transactionId, withVariationId: variationId)
            return .success(profile)
        }
    }
}

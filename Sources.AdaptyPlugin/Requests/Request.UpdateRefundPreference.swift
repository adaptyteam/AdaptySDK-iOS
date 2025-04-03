//
//  Request.UpdateRefundPreference.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct UpdateRefundPreference: AdaptyPluginRequest {
        static let method = "update_refund_preference"

        let refundPreference: AdaptyRefundPreference

        enum CodingKeys: String, CodingKey {
            case refundPreference = "refund_preference"
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.updateRefundPreference(refundPreference)
            return .success()
        }
    }
}

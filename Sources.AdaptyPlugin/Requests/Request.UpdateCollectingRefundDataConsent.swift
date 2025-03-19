//
//  Request.UpdateCollectingRefundDataConsent.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 19.03.2025.
//

import Adapty
import Foundation

extension Request {
    struct UpdateCollectingRefundDataConsent: AdaptyPluginRequest {
        static let method = "update_collecting_refund_data_consent"

        let consent: Bool

        enum CodingKeys: CodingKey {
            case consent
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.updateCollectingRefundDataConsent(consent)
            return .success()
        }
    }
}

//
//  Request.LogShowPaywall.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct LogShowPaywall: AdaptyPluginRequest {
        static let method = "log_show_paywall"

        let paywall: AdaptyPaywall

        enum CodingKeys: CodingKey {
            case paywall
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.logShowPaywall(paywall)
            return .success()
        }
    }
}

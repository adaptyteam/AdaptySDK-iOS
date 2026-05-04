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
        static let method = "log_show_paywall" // TODO: x

//        let paywall: AdaptyPaywall
//
//        enum CodingKeys: CodingKey {
//            case paywall
//        }

        func execute() async throws -> AdaptyJsonData {
            return .failure(nil)
//            try await Adapty.logShowPaywall(paywall)
//            return .success()
        }
    }
}

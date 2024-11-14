//
//  Request.RestorePurchases.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct RestorePurchases: AdaptyPluginRequest {
        static let method = "restore_purchases"

        func execute() async throws -> AdaptyJsonData {
            let profile = try await Adapty.restorePurchases()
            return .success(profile)
        }
    }
}

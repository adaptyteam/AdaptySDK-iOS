//
//  Request.Logout.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct Logout: AdaptyPluginRequest {
        static let method = "logout"

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.logout()
            return .success()
        }
    }
}

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

        init(from jsonDictionary: AdaptyJsonDictionary) throws {}

        init() {}

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.logout()
            return .success()
        }
    }
}

public extension AdaptyPlugin {
    @objc static func logout(
        customerUserId: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        execute(with: completion) { Request.Logout() }
    }
}

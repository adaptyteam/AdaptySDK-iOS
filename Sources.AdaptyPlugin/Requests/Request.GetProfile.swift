//
//  Request.GetProfile.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetProfile: AdaptyPluginRequest {
        static let method = "get_profile"

        func execute() async throws -> AdaptyJsonData {
            try .success(await Adapty.getProfile())
        }
    }
}

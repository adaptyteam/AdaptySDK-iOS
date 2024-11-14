//
//  Request.IsActivated.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 06.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct IsActivated: AdaptyPluginRequest {
        static let method = "is_activated"

        func execute() async throws -> AdaptyJsonData {
            .success(await Adapty.isActivated)
        }
    }
}

//
//  Request.LogShowFlow.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct LogShowFlow: AdaptyPluginRequest {
        static let method = "log_show_flow"

        let flow: AdaptyFlow

        enum CodingKeys: CodingKey {
            case flow
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.logShowFlow(flow)
            return .success()
        }
    }
}

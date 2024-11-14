//
//  Request.LogShowOnboarding.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct LogShowOnboarding: AdaptyPluginRequest {
        static let method = "log_show_onboarding"

        let params: AdaptyOnboardingScreenParameters

        enum CodingKeys: CodingKey {
            case params
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.logShowOnboarding(params)
            return .success()
        }
    }
}

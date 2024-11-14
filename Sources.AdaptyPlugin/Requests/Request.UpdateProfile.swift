//
//  Request.UpdateProfile.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct UpdateProfile: AdaptyPluginRequest {
        static let method = "update_profile"

        let params: AdaptyProfileParameters

        enum CodingKeys: CodingKey {
            case params
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.updateProfile(params: params)
            return .success()
        }
    }
}

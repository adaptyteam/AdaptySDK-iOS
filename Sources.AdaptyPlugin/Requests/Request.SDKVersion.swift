//
//  Request.SDKVersion.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 06.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetSDKVersion: AdaptyPluginRequest {
        static let method = "get_sdk_version"

        func execute() async throws -> AdaptyJsonData {
            .success(Adapty.SDKVersion)
        }
    }
}

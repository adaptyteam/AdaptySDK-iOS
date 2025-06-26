//
//  Request.GetCurrentInstallationStatus.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 25.06.2025.
//

import Adapty
import Foundation

extension Request {
    struct GetCurrentInstallationStatus: AdaptyPluginRequest {
        static let method = "get_current_installation_status"

        func execute() async throws -> AdaptyJsonData {
            try .success(await Adapty.getCurrentInstallationStatus())
        }
    }
}

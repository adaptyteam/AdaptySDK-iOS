//
//  Request.AdaptyUIActivate.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Request {
    struct AdaptyUIActivate: AdaptyPluginRequest {
        static let method = "adapty_ui_activate"

        let configuration: AdaptyUI.Configuration

        enum CodingKeys: CodingKey {
            case configuration
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.activate(configuration: configuration)
            return .success()
        }
    }
}

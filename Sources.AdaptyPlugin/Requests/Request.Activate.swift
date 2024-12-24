//
//  Request.Activate.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension Request {
    struct Activate: AdaptyPluginRequest {
        static let method = "activate"

        let configuration: AdaptyConfiguration
        let activateUI: Bool
        let uiConfiguration: AdaptyUI.Configuration

        enum CodingKeys: CodingKey {
            case configuration
        }

        enum ConfigurationCodingKeys: String, CodingKey {
            case activateUI = "activate_ui"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let builder = try container.decode(AdaptyConfiguration.Builder.self, forKey: .configuration)
            guard builder.crossPlatformSDK != nil else {
                throw AdaptyPluginInternalError.notExist("cross platform sdk version or name not set")
            }
            self.configuration = builder.build()

            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *),
               try container
               .nestedContainer(keyedBy: ConfigurationCodingKeys.self, forKey: .configuration)
               .decodeIfPresent(Bool.self, forKey: .activateUI) ?? false
            {
                self.activateUI = true
                self.uiConfiguration = try container.decode(AdaptyUI.Configuration.self, forKey: .configuration)
            } else {
                self.activateUI = false
                self.uiConfiguration = AdaptyUI.Configuration.default
            }
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.activate(with: configuration)
            if activateUI, #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                try await AdaptyUI.activate(configuration: uiConfiguration)
            }
            return .success()
        }
    }
}

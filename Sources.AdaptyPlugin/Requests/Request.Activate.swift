//
//  Request.Activate.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct Activate: AdaptyPluginRequest {
        static let method = "activate"

        let configuration: AdaptyConfiguration

        enum CodingKeys: CodingKey {
            case configuration
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let builder = try container.decode(AdaptyConfiguration.Builder.self, forKey: .configuration)
            guard builder.crossPlatformSDK != nil else {
                throw AdaptyPluginDecodingError.notExist(key: "cross platform sdk version or name not set")
            }
            self.configuration = builder.build()
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.activate(with: configuration)
            return .success()
        }
    }
}

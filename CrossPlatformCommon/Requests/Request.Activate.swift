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
        static let method = Method.activate

        let configuration: AdaptyConfiguration

        enum CodingKeys: CodingKey {
            case configuration
        }

        init(from params: AdaptyJsonDictionary) throws {
            try self.init(
                configuration: params.value(forKey: CodingKeys.configuration)
            )
        }

        init(configuration: KeyValue) throws {
            if let configuration = try? configuration.cast(AdaptyConfiguration.self) {
                self.configuration = configuration
            } else {
                let builder = try configuration.decode(AdaptyConfiguration.Builder.self)
                guard builder.crossPlatformSDK != nil else {
                    throw AdaptyPluginDecodingError.notExist(key: "cross platform sdk version or name not set")
                }
                self.configuration = builder.build()
            }
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

public extension AdaptyPlugin {
    @objc static func activate(
        configuration: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.Activate.CodingKeys
        execute(with: completion) { try Request.Activate(
            configuration: .init(key: CodingKeys.configuration, value: configuration)
        ) }
    }
}

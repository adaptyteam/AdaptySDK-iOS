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
                self.configuration = builder.build()
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let builder = try container.decode(AdaptyConfiguration.Builder.self, forKey: .configuration)
            self.configuration = builder.build()
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.activate(with: configuration)
            return .success()
        }
    }
}

private enum CodingKeys: CodingKey {
    case configuration
}

public extension AdaptyPlugin {
    @objc static func activate(
        configuration: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        withCompletion(completion) {
            await Request.Activate.execute {
                try Request.Activate(
                    configuration: .init(key: CodingKeys.configuration, value: configuration)
                )
            }
        }
    }
}

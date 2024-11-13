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
        static let method = Method.adaptyUIActivate

        let configuration: AdaptyUI.Configuration

        enum CodingKeys: CodingKey {
            case configuration
        }

        init(from params: AdaptyJsonDictionary) throws {
            try self.init(
                configuration: params.value(forKey: CodingKeys.configuration)
            )
        }

        init(configuration: KeyValue) throws {
            self.configuration = try configuration.decode(AdaptyUI.Configuration.self)
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.activate(configuration: configuration)
            return .success()
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyPlugin {
    @objc static func adaptyUIActivate(
        configuration: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.AdaptyUIActivate.CodingKeys
        execute(with: completion) { try Request.AdaptyUIActivate(
            configuration: KeyValue(key: CodingKeys.configuration, value: configuration)
        ) }
    }
}

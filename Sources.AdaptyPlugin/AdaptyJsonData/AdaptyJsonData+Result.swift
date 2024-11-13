//
//  AdaptyJsonData+Result.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Foundation

extension AdaptyJsonData {
    private enum Result: Encodable {
        case success(Encodable)
        case failure(AdaptyPluginError)

        enum CodingKeys: String, CodingKey {
            case success
            case error
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .success(value):
                try container.encode(value, forKey: .success)
            case let .failure(value):
                try container.encode(value, forKey: .error)
            }
        }

        var asAdaptyJsonData: Data {
            AdaptyPlugin.encoder.encodeOtherwiseEncodedError(self)
        }
    }

    static func success(_ value: Encodable) -> AdaptyJsonData {
        Result.success(value).asAdaptyJsonData
    }

    static func success() -> AdaptyJsonData {
        Result.success(true).asAdaptyJsonData
    }

    static func failure(_ error: AdaptyPluginError?) -> AdaptyJsonData {
        guard let error else {
            return .success()
        }
        return Result.failure(error).asAdaptyJsonData
    }
}

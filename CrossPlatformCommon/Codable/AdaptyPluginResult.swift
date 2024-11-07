//
//  AdaptyPluginResult.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 06.11.2024.
//

import Adapty
import Foundation

public enum AdaptyPluginResult: Encodable {
    case success(Encodable)
    case failure(AdaptyPluginError)

    enum CodingKeys: String, CodingKey {
        case success
        case error
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .success(value):
            try container.encode(value, forKey: .success)
        case let .failure(value):
            try container.encode(value, forKey: .error)
        }
    }
}

extension AdaptyPluginResult {
    var asAdaptyJsonData: Data {
        do {
            return try AdaptyPlugin.encoder.encode(self)
        } catch {
            let error = AdaptyPluginError.encodingFailed(error)
            return try! AdaptyPlugin.encoder.encode(error)
        }
    }
}

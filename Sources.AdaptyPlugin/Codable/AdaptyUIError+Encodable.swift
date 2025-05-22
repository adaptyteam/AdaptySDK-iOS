//
//  AdaptyUIError+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.05.2025.
//

import AdaptyUI
import Foundation

extension AdaptyUIError: Encodable {
    enum CodingKeys: String, CodingKey {
        case errorCode = "adapty_code"
        case debugDescription = "message"
        case description = "detail"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(errorCode, forKey: .errorCode)
        try container.encode(debugDescription, forKey: .debugDescription)
        try container.encode(description, forKey: .description)
    }

    var asAdaptyPluginError: AdaptyPluginError {
        let detail: String
        do {
            detail = try AdaptyPlugin.encoder.encode(self).asAdaptyJsonString
        } catch {
            detail = description
        }

        return AdaptyPluginError(
            errorCode: errorCode,
            message: debugDescription,
            detail: detail
        )
    }

    @inlinable
    public var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}

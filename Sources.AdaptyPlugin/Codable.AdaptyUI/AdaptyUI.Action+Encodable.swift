//
//  AdaptyUI.Action+Encodable.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI.Action: Encodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .close:
            try container.encode("close", forKey: .type)
        case .openURL(let url):
            try container.encode("open_url", forKey: .type)
            try container.encode(url.absoluteString, forKey: .value)
        case .custom(let id):
            try container.encode("custom", forKey: .type)
            try container.encode(id, forKey: .value)
        }
    }

    @inlinable
    public var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}

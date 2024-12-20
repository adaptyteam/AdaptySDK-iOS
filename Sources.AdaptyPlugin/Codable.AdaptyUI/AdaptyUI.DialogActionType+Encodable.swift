//
//  AdaptyUI.DialogActionType.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.12.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI.DialogActionType: Encodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .default:
            try container.encode("default")
        case .secondary:
            try container.encode("secondary")
        }
    }
}

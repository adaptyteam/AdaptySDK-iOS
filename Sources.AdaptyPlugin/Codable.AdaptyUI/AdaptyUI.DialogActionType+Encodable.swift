//
//  AdaptyUI.DialogActionType.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.12.2024.
//

import AdaptyUI
import Foundation

extension AdaptyUI.DialogActionType: Encodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .primary:
            try container.encode("primary")
        case .secondary:
            try container.encode("secondary")
        }
    }
}

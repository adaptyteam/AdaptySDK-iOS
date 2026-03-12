//
//  Schema.AssetReference.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 09.01.2026.
//

import Foundation

extension Schema {
    typealias AssetReference = VC.AssetReference
}

extension Schema.AssetReference {
    @inlinable
    var isColor: Bool {
        switch self {
        case .color:
            true
        default:
            false
        }
    }
}

extension Schema.AssetReference: Codable {
    package init(from decoder: Decoder) throws {
        guard let value = try? decoder.singleValueContainer().decode(String.self) else {
            self = try .variable(Schema.Variable(from: decoder))
            return
        }

        self =
            if let color = Schema.Color(rawValue: value) {
                .color(color)
            } else {
                .assetId(value)
            }
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .assetId(value):
            try container.encode(value)
        case let .color(color):
            try container.encode(color)
        case let .variable(variable):
            try container.encode(variable)
        }
    }
}

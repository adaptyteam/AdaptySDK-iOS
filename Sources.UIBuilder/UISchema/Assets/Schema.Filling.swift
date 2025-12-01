//
//  Schema.Filling.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema {
    typealias Filling = VC.Filling
}

extension Schema.Filling {
    static func assetType(_ type: String) -> Bool {
        type == Schema.Color.assetType || Schema.ColorGradient.assetType(type)
    }
}

extension Schema.Filling: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
        case customId = "custom_id"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(String.self, forKey: .type) {
        case Schema.Color.assetType:
            self = try .solidColor(.init(
                customId: container.decodeIfPresent(String.self, forKey: .customId),
                data: container.decode(Schema.Color.self, forKey: .value).data
            ))
        case let type where Schema.ColorGradient.assetType(type):
            self = try .colorGradient(Schema.ColorGradient(from: decoder))
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.type], debugDescription: "unknown color assset type"))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        switch self {
        case let .solidColor(color):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(Schema.Color.assetType, forKey: .type)
            try container.encodeIfPresent(color.customId, forKey: .customId)
            try container.encode(color, forKey: .value)
        case let .colorGradient(gradient):
            try gradient.encode(to: encoder)
        }
    }
}

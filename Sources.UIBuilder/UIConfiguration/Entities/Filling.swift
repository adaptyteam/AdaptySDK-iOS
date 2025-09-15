//
//  Filling.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension AdaptyUIConfiguration {
    enum Filling: Sendable {
        static let `default` = Filling.solidColor(Color.black)

        case solidColor(AdaptyUIConfiguration.Color)
        case colorGradient(AdaptyUIConfiguration.ColorGradient)

        package var asSolidColor: AdaptyUIConfiguration.Color? {
            switch self {
            case let .solidColor(value): value
            default: nil
            }
        }
    }
}

extension AdaptyUIConfiguration.Filling: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .solidColor(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .colorGradient(value):
            hasher.combine(2)
            hasher.combine(value)
        }
    }
}

package extension AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.Filling> {
    var hasColorGradient: Bool {
        switch self {
        case .same(.solidColor), .different(light: .solidColor, dark: .solidColor):
            false
        default:
            true
        }
    }

    var asSolidColor: AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.Color>? {
        switch self {
        case let .same(.solidColor(value)):
            .same(value)
        case let .different(.solidColor(light), .solidColor(dark)):
            .different(light: light, dark: dark)
        default:
            nil
        }
    }
}

extension AdaptyUIConfiguration.Filling: Codable {
    static func assetType(_ type: String) -> Bool {
        type == AdaptyUIConfiguration.Color.assetType || AdaptyUIConfiguration.ColorGradient.assetType(type)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case value
        case customId = "custom_id"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(String.self, forKey: .type) {
        case AdaptyUIConfiguration.Color.assetType:
            self = try .solidColor(.init(
                customId: container.decodeIfPresent(String.self, forKey: .customId),
                data: container.decode(AdaptyUIConfiguration.Color.self, forKey: .value).data
            ))
        case let type where AdaptyUIConfiguration.ColorGradient.assetType(type):
            self = try .colorGradient(AdaptyUIConfiguration.ColorGradient(from: decoder))
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.type], debugDescription: "unknown color assset type"))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        switch self {
        case let .solidColor(color):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(AdaptyUIConfiguration.Color.assetType, forKey: .type)
            try container.encodeIfPresent(color.customId, forKey: .customId)
            try container.encode(color, forKey: .value)
        case let .colorGradient(gradient):
            try gradient.encode(to: encoder)
        }
    }
}

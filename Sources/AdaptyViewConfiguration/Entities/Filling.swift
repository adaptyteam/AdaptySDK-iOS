//
//  Filling.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension AdaptyViewConfiguration {
    enum Filling: Sendable {
        static let `default` = Filling.solidColor(Color.black)

        case solidColor(AdaptyViewConfiguration.Color)
        case colorGradient(AdaptyViewConfiguration.ColorGradient)

        package var asSolidColor: AdaptyViewConfiguration.Color? {
            switch self {
            case let .solidColor(value): value
            default: nil
            }
        }

        package var asColorGradient: AdaptyViewConfiguration.ColorGradient {
            switch self {
            case let .solidColor(value):
                AdaptyViewConfiguration.ColorGradient(
                    kind: .linear,
                    start: .zero,
                    end: .one,
                    items: [.init(color: value, p: 0.5)]
                )
            case let .colorGradient(value):
                value
            }
        }
    }
}

extension AdaptyViewConfiguration.Filling: Hashable {
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

package extension AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling> {
    var hasColorGradient: Bool {
        switch self {
        case .same(.solidColor), .different(light: .solidColor, dark: .solidColor):
            false
        default:
            true
        }
    }

    var asSolidColor: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Color>? {
        switch self {
        case let .same(.solidColor(value)):
            .same(value)
        case let .different(.solidColor(light), .solidColor(dark)):
            .different(light: light, dark: dark)
        default:
            nil
        }
    }

    var asColorGradient: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.ColorGradient> {
        switch self {
        case let .same(value):
            .same(value.asColorGradient)
        case let .different(light, dark):
            .different(light: light.asColorGradient, dark: dark.asColorGradient)
        }
    }
}

extension AdaptyViewConfiguration.Filling: Decodable {
    static func assetType(_ type: String) -> Bool {
        type == AdaptyViewConfiguration.Color.assetType || AdaptyViewConfiguration.ColorGradient.assetType(type)
    }

    package init(from decoder: Decoder) throws {
        enum CodingKeys: String, CodingKey {
            case type
            case value
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(String.self, forKey: .type) {
        case AdaptyViewConfiguration.Color.assetType:
            self = try .solidColor(container.decode(AdaptyViewConfiguration.Color.self, forKey: .value))
        case let type where AdaptyViewConfiguration.ColorGradient.assetType(type):
            self = try .colorGradient(AdaptyViewConfiguration.ColorGradient(from: decoder))
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.type], debugDescription: "unknown color assset type"))
        }
    }
}

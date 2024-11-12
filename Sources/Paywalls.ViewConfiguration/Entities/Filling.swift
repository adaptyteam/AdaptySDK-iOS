//
//  Filling.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension AdaptyUICore {
    enum Filling: Sendable {
        static let `default` = Filling.solidColor(Color.black)

        case solidColor(AdaptyUICore.Color)
        case colorGradient(AdaptyUICore.ColorGradient)

        package var asSolidColor: AdaptyUICore.Color? {
            switch self {
            case let .solidColor(value): value
            default: nil
            }
        }

        package var asColorGradient: AdaptyUICore.ColorGradient {
            switch self {
            case let .solidColor(value):
                AdaptyUICore.ColorGradient(
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

extension AdaptyUICore.Filling: Hashable {
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

package extension AdaptyUICore.Mode<AdaptyUICore.Filling> {
    var hasColorGradient: Bool {
        switch self {
        case .same(.solidColor), .different(light: .solidColor, dark: .solidColor):
            false
        default:
            true
        }
    }

    var asSolidColor: AdaptyUICore.Mode<AdaptyUICore.Color>? {
        switch self {
        case let .same(.solidColor(value)):
            .same(value)
        case let .different(.solidColor(light), .solidColor(dark)):
            .different(light: light, dark: dark)
        default:
            nil
        }
    }

    var asColorGradient: AdaptyUICore.Mode<AdaptyUICore.ColorGradient> {
        switch self {
        case let .same(value):
            .same(value.asColorGradient)
        case let .different(light, dark):
            .different(light: light.asColorGradient, dark: dark.asColorGradient)
        }
    }
}

extension AdaptyUICore.Filling: Decodable {
    static func assetType(_ type: String) -> Bool {
        type == AdaptyUICore.Color.assetType || AdaptyUICore.ColorGradient.assetType(type)
    }

    package init(from decoder: Decoder) throws {
        enum CodingKeys: String, CodingKey {
            case type
            case value
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(String.self, forKey: .type) {
        case AdaptyUICore.Color.assetType:
            self = try .solidColor(container.decode(AdaptyUICore.Color.self, forKey: .value))
        case let type where AdaptyUICore.ColorGradient.assetType(type):
            self = try .colorGradient(AdaptyUICore.ColorGradient(from: decoder))
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.type], debugDescription: "unknown color assset type"))
        }
    }
}

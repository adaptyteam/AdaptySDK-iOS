//
//  Filling.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension AdaptyUI {
    enum Filling: Sendable {
        static let `default` = Filling.solidColor(Color.black)

        case solidColor(AdaptyUI.Color)
        case colorGradient(AdaptyUI.ColorGradient)

        package var asSolidColor: AdaptyUI.Color? {
            switch self {
            case let .solidColor(value): value
            default: nil
            }
        }

        package var asColorGradient: AdaptyUI.ColorGradient {
            switch self {
            case let .solidColor(value):
                AdaptyUI.ColorGradient(
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

extension AdaptyUI.Filling: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .solidColor(value):
            hasher.combine(value)
        case let .colorGradient(value):
            hasher.combine(value)
        }
    }
}

package extension AdaptyUI.Mode<AdaptyUI.Filling> {
    var hasColorGradient: Bool {
        switch self {
        case .same(.solidColor), .different(light: .solidColor, dark: .solidColor):
            false
        default:
            false
        }
    }

    var asSolidColor: AdaptyUI.Mode<AdaptyUI.Color>? {
        switch self {
        case let .same(.solidColor(value)):
            .same(value)
        case let .different(.solidColor(light), .solidColor(dark)):
            .different(light: light, dark: dark)
        default:
            nil
        }
    }

    var asColorGradient: AdaptyUI.Mode<AdaptyUI.ColorGradient> {
        switch self {
        case let .same(value):
            .same(value.asColorGradient)
        case let .different(light, dark):
            .different(light: light.asColorGradient, dark: dark.asColorGradient)
        }
    }
}

extension AdaptyUI.Filling: Decodable {
    static func assetType(_ type: String) -> Bool {
        type == AdaptyUI.Color.assetType || AdaptyUI.ColorGradient.assetType(type)
    }

    package init(from decoder: Decoder) throws {
        enum CodingKeys: String, CodingKey {
            case type
            case value
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(String.self, forKey: .type) {
        case AdaptyUI.Color.assetType:
            self = try .solidColor(container.decode(AdaptyUI.Color.self, forKey: .value))
        case let type where AdaptyUI.ColorGradient.assetType(type):
            self = try .colorGradient(AdaptyUI.ColorGradient(from: decoder))
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.type], debugDescription: "unknown color assset type"))
        }
    }
}

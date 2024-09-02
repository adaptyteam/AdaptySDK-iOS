//
//  Filling.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension AdaptyUI {
    enum Filling: Sendable {
        static let `default` = Filling.color(Color.black)

        case color(AdaptyUI.Color)
        case colorGradient(AdaptyUI.ColorGradient)

        package var asColor: AdaptyUI.Color? {
            switch self {
            case let .color(value): value
            default: nil
            }
        }

        package var asColorGradient: AdaptyUI.ColorGradient {
            switch self {
            case let .color(value):
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
        case let .color(value):
            hasher.combine(value)
        case let .colorGradient(value):
            hasher.combine(value)
        }
    }
}

#if DEBUG

    package extension AdaptyUI.Filling {
        static func createColor(value: AdaptyUI.Color) -> Self {
            .color(value)
        }

        static func createGradient(value: AdaptyUI.ColorGradient) -> Self {
            .colorGradient(value)
        }
    }
#endif

extension AdaptyUI.Mode<AdaptyUI.Filling> {
    var isColorGradient: Bool {
        switch self {
        case .same(.color), .different(light: .color, dark: .color):
            false
        default:
            false
        }
    }

    var asColor: AdaptyUI.Mode<AdaptyUI.Color>? {
        switch self {
        case let .same(.color(value)):
            .same(value)
        case let .different(.color(light), .color(dark)):
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
            self = try .color(container.decode(AdaptyUI.Color.self, forKey: .value))
        case let type where AdaptyUI.ColorGradient.assetType(type):
            self = try .colorGradient(AdaptyUI.ColorGradient(from: decoder))
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.type], debugDescription: "unknown color assset type"))
        }
    }
}

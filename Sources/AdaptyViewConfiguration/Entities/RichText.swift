//
//  RichText.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyViewConfiguration {
    package struct RichText: Sendable, Hashable {
        static let empty = RichText(items: [], fallback: nil)

        package let items: [RichText.Item]
        package let fallback: [RichText.Item]?

        package var isEmpty: Bool { items.isEmpty }

        package enum Item: Sendable {
            case text(String, TextAttributes)
            case tag(String, TextAttributes)
            case image(AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.ImageData>?, TextAttributes)
        }

        package struct TextAttributes: Sendable, Hashable {
            package let font: AdaptyViewConfiguration.Font
            package let size: Double
            package let txtColor: Mode<Filling>
            package let imageTintColor: Mode<Filling>?
            package let background: Mode<Filling>?
            package let strike: Bool
            package let underline: Bool
        }
    }
}

extension AdaptyViewConfiguration.RichText.Item: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value, attributes):
            hasher.combine(1)
            hasher.combine(value)
            hasher.combine(attributes)
        case let .tag(value, attributes):
            hasher.combine(2)
            hasher.combine(value)
            hasher.combine(attributes)
        case let .image(value, attributes):
            hasher.combine(3)
            hasher.combine(value)
            hasher.combine(attributes)
        }
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.RichText {
        static func create(
            items: [AdaptyViewConfiguration.RichText.Item],
            fallback: [AdaptyViewConfiguration.RichText.Item]? = nil
        ) -> Self {
            .init(
                items: items,
                fallback: fallback
            )
        }
    }

    package extension AdaptyViewConfiguration.RichText.TextAttributes {
        static func create(
            font: AdaptyViewConfiguration.Font,
            size: Double? = nil,
            txtColor: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>? = nil,
            imgTintColor: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>? = nil,
            background: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>? = nil,
            strike: Bool = false,
            underline: Bool = false
        ) -> Self {
            .init(
                font: font,
                size: size ?? font.defaultSize,
                txtColor: txtColor ?? .same(font.defaultColor),
                imageTintColor: imgTintColor,
                background: background,
                strike: strike,
                underline: underline
            )
        }
    }
#endif

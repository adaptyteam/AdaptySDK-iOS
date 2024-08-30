//
//  RichText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI {
    package struct RichText: Hashable, Sendable {
        static let empty = RichText(items: [], fallback: nil)

        package let items: [RichText.Item]
        package let fallback: [RichText.Item]?

        package var isEmpty: Bool { items.isEmpty }

        package enum Item: Sendable {
            case text(String, TextAttributes)
            case tag(String, TextAttributes)
            case image(AdaptyUI.Mode<AdaptyUI.ImageData>?, TextAttributes)
        }

        package struct TextAttributes: Hashable, Sendable {
            package let font: AdaptyUI.Font
            package let size: Double
            package let txtColor: Mode<Filling>
            package let imgTintColor: Mode<Filling>?
            package let background: Mode<Filling>?
            package let strike: Bool
            package let underline: Bool
        }
    }
}

extension AdaptyUI.RichText.Item: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value, attr),
             let .tag(value, attr):
            hasher.combine(value)
            hasher.combine(attr)
        case let .image(value, attr):
            hasher.combine(value)
            hasher.combine(attr)
        }
    }
}

#if DEBUG
    package extension AdaptyUI.RichText {
        static func create(
            items: [AdaptyUI.RichText.Item],
            fallback: [AdaptyUI.RichText.Item]? = nil
        ) -> Self {
            .init(
                items: items,
                fallback: fallback
            )
        }
    }

    package extension AdaptyUI.RichText.TextAttributes {
        static func create(
            font: AdaptyUI.Font,
            size: Double? = nil,
            txtColor: AdaptyUI.Mode<AdaptyUI.Filling>? = nil,
            imgTintColor: AdaptyUI.Mode<AdaptyUI.Filling>? = nil,
            background: AdaptyUI.Mode<AdaptyUI.Filling>? = nil,
            strike: Bool = false,
            underline: Bool = false
        ) -> Self {
            .init(
                font: font,
                size: size ?? font.defaultSize,
                txtColor: txtColor ?? .same(font.defaultColor),
                imgTintColor: imgTintColor,
                background: background,
                strike: strike,
                underline: underline
            )
        }
    }
#endif

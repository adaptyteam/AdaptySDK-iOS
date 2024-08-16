//
//  RichText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI {
    package struct RichText: Sendable, Hashable {
        static let empty = RichText(items: [], fallback: nil)

        package let items: [RichText.Item]
        package let fallback: [RichText.Item]?

        package var isEmpty: Bool { items.isEmpty }

        package enum Item: Sendable {
            case text(String, TextAttributes)
            case tag(String, TextAttributes)
            case image(AdaptyUI.ImageData?, TextAttributes)
        }

        package struct TextAttributes: Sendable, Hashable {
            package let font: AdaptyUI.Font
            package let size: Double
            package let txtColor: AdaptyUI.ColorFilling
            package let imgTintColor: AdaptyUI.ColorFilling?
            package let background: AdaptyUI.ColorFilling?
            package let strike: Bool
            package let underline: Bool
        }
    }
}

extension AdaptyUI.RichText.Item: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value, attr):
            hasher.combine(1)
            hasher.combine(value)
            hasher.combine(attr)
        case let .tag(value, attr):
            hasher.combine(2)
            hasher.combine(value)
            hasher.combine(attr)
        case let .image(value, attr):
            hasher.combine(3)
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
            txtColor: AdaptyUI.ColorFilling? = nil,
            imgTintColor: AdaptyUI.ColorFilling? = nil,
            background: AdaptyUI.ColorFilling? = nil,
            strike: Bool = false,
            underline: Bool = false
        ) -> Self {
            .init(
                font: font,
                size: size ?? font.defaultSize,
                txtColor: txtColor ?? font.defaultColor,
                imgTintColor: imgTintColor,
                background: background,
                strike: strike,
                underline: underline
            )
        }
    }
#endif

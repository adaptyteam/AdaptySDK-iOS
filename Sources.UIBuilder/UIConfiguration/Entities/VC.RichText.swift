//
//  VC.RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

package extension VC {
    struct RichText: Sendable, Hashable {
        static let empty = RichText(items: [], fallback: nil)

        package let items: [RichText.Item]
        package let fallback: [RichText.Item]?

        package var isEmpty: Bool { items.isEmpty }

        package enum Item: Sendable {
            case text(String, TextAttributes)
            case tag(String, TextAttributes)
            case image(VC.Mode<VC.ImageData>?, TextAttributes)
        }

        package struct TextAttributes: Sendable, Hashable {
            package let font: VC.Font
            package let size: Double
            package let txtColor: Mode<Filling>
            package let imageTintColor: Mode<Filling>?
            package let background: Mode<Filling>?
            package let strike: Bool
            package let underline: Bool
        }
    }
}

extension VC.RichText.Item: Hashable {
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
package extension VC.RichText {
    static func create(
        items: [VC.RichText.Item],
        fallback: [VC.RichText.Item]? = nil
    ) -> Self {
        .init(
            items: items,
            fallback: fallback
        )
    }
}

package extension VC.RichText.TextAttributes {
    static func create(
        font: VC.Font,
        size: Double? = nil,
        txtColor: VC.Mode<VC.Filling>? = nil,
        imgTintColor: VC.Mode<VC.Filling>? = nil,
        background: VC.Mode<VC.Filling>? = nil,
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

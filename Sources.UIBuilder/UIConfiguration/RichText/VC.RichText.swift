//
//  VC.RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

package extension VC {
    struct RichText: Sendable, Hashable {
        package let items: [Item]
        package let fallback: [Item]?
    }
}

package extension VC.RichText {
    var isEmpty: Bool { items.isEmpty }
}

extension VC.RichText {
    static let empty = Self(items: [], fallback: nil)
}

#if DEBUG
package extension VC.RichText {
    static func create(
        items: [Item],
        fallback: [Item]? = nil
    ) -> Self {
        .init(
            items: items,
            fallback: fallback
        )
    }
}

package extension VC.RichText.Attributes {
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

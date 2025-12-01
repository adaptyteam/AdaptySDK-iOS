//
//  VC.Text.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

package extension VC {
    struct Text: Sendable, Hashable {
        package let value: Value
        package let horizontalAlign: HorizontalAlignment
        package let maxRows: Int?
        package let overflowMode: Set<OverflowMode>
    }
}

extension VC.Text {
    static let `default` = Self(
        value: .text(.empty),
        horizontalAlign: .leading,
        maxRows: nil,
        overflowMode: []
    )
}

#if DEBUG
package extension VC.Text {
    static func create(
        text: [VC.RichText.Item],
        horizontalAlign: VC.HorizontalAlignment = `default`.horizontalAlign,
        maxRows: Int? = `default`.maxRows,
        overflowMode: Set<OverflowMode> = `default`.overflowMode
    ) -> Self {
        .init(
            value: .text(.create(items: text)),
            horizontalAlign: horizontalAlign,
            maxRows: maxRows,
            overflowMode: overflowMode
        )
    }

    static func create(
        text: VC.RichText,
        horizontalAlign: VC.HorizontalAlignment = `default`.horizontalAlign,
        maxRows: Int? = `default`.maxRows,
        overflowMode: Set<OverflowMode> = `default`.overflowMode
    ) -> Self {
        .init(
            value: .text(text),
            horizontalAlign: horizontalAlign,
            maxRows: maxRows,
            overflowMode: overflowMode
        )
    }

    static func create(
        value: Value,
        horizontalAlign: VC.HorizontalAlignment = `default`.horizontalAlign,
        maxRows: Int? = `default`.maxRows,
        overflowMode: Set<OverflowMode> = `default`.overflowMode
    ) -> Self {
        .init(
            value: value,
            horizontalAlign: horizontalAlign,
            maxRows: maxRows,
            overflowMode: overflowMode
        )
    }
}
#endif

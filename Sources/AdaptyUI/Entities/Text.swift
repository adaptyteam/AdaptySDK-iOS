//
//  Text.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Text {
        static let empty = AdaptyUI.Text(
            value: .text(.empty),
            maxRows: nil,
            overflowMode: .empty
        )

        package let value: Value
        package let maxRows: Int?
        package let overflowMode: Set<OverflowMode>

        package enum Value {
            case text(RichText)
            case productText(AdaptyUI.LazyLocalisedProductText)
            case selectedProductText(AdaptyUI.LazyLocalisedUnknownProductText)
        }
    }
}

#if DEBUG
    package extension AdaptyUI.Text {
        static func create(
            text: [AdaptyUI.RichText.Item],
            maxRows: Int? = empty.maxRows,
            overflowMode: Set<AdaptyUI.Text.OverflowMode> = empty.overflowMode
        ) -> Self {
            .init(
                value: .text(.create(items: text)),
                maxRows: maxRows,
                overflowMode: overflowMode
            )
        }

        static func create(
            text: AdaptyUI.RichText,
            maxRows: Int? = empty.maxRows,
            overflowMode: Set<AdaptyUI.Text.OverflowMode> = empty.overflowMode
        ) -> Self {
            .init(
                value: .text(text),
                maxRows: maxRows,
                overflowMode: overflowMode
            )
        }

        static func create(
            value: AdaptyUI.Text.Value,
            maxRows: Int? = empty.maxRows,
            overflowMode: Set<AdaptyUI.Text.OverflowMode> = empty.overflowMode
        ) -> Self {
            .init(
                value: value,
                maxRows: maxRows,
                overflowMode: overflowMode
            )
        }
    }
#endif

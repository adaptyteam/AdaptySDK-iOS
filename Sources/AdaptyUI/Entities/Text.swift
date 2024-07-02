//
//  Text.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Text: Hashable, Sendable {
        static let `default` = AdaptyUI.Text(
            value: .text(.empty),
            horizontalAlign: .leading,
            maxRows: nil,
            overflowMode: []
        )

        package let value: Value
        package let horizontalAlign: HorizontalAlignment
        package let maxRows: Int?
        package let overflowMode: Set<OverflowMode>

        package enum Value: Sendable {
            case text(RichText)
            case productText(LazyLocalisedProductText)
            case selectedProductText(LazyLocalisedUnknownProductText)
        }
    }
}

extension AdaptyUI.Text.Value: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value):
            hasher.combine(value)
        case let .productText(value):
            hasher.combine(value)
        case let .selectedProductText(value):
            hasher.combine(value)
        }
    }
}

#if DEBUG
    package extension AdaptyUI.Text {
        static func create(
            text: [AdaptyUI.RichText.Item],
            horizontalAlign: AdaptyUI.HorizontalAlignment = `default`.horizontalAlign,
            maxRows: Int? = `default`.maxRows,
            overflowMode: Set<AdaptyUI.Text.OverflowMode> = `default`.overflowMode
        ) -> Self {
            .init(
                value: .text(.create(items: text)),
                horizontalAlign: horizontalAlign,
                maxRows: maxRows,
                overflowMode: overflowMode
            )
        }

        static func create(
            text: AdaptyUI.RichText,
            horizontalAlign: AdaptyUI.HorizontalAlignment = `default`.horizontalAlign,
            maxRows: Int? = `default`.maxRows,
            overflowMode: Set<AdaptyUI.Text.OverflowMode> = `default`.overflowMode
        ) -> Self {
            .init(
                value: .text(text),
                horizontalAlign: horizontalAlign,
                maxRows: maxRows,
                overflowMode: overflowMode
            )
        }

        static func create(
            value: AdaptyUI.Text.Value,
            horizontalAlign: AdaptyUI.HorizontalAlignment = `default`.horizontalAlign,
            maxRows: Int? = `default`.maxRows,
            overflowMode: Set<AdaptyUI.Text.OverflowMode> = `default`.overflowMode
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

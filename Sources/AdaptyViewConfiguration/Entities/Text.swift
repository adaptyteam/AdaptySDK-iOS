//
//  Text.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct Text: Sendable, Hashable {
        static let `default` = AdaptyViewConfiguration.Text(
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
            case productText(LazyLocalizedProductText)
            case selectedProductText(LazyLocalizedUnknownProductText)
        }
    }
}

extension AdaptyViewConfiguration.Text.Value: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .productText(value):
            hasher.combine(2)
            hasher.combine(value)
        case let .selectedProductText(value):
            hasher.combine(3)
            hasher.combine(value)
        }
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Text {
        static func create(
            text: [AdaptyViewConfiguration.RichText.Item],
            horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment = `default`.horizontalAlign,
            maxRows: Int? = `default`.maxRows,
            overflowMode: Set<AdaptyViewConfiguration.Text.OverflowMode> = `default`.overflowMode
        ) -> Self {
            .init(
                value: .text(.create(items: text)),
                horizontalAlign: horizontalAlign,
                maxRows: maxRows,
                overflowMode: overflowMode
            )
        }

        static func create(
            text: AdaptyViewConfiguration.RichText,
            horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment = `default`.horizontalAlign,
            maxRows: Int? = `default`.maxRows,
            overflowMode: Set<AdaptyViewConfiguration.Text.OverflowMode> = `default`.overflowMode
        ) -> Self {
            .init(
                value: .text(text),
                horizontalAlign: horizontalAlign,
                maxRows: maxRows,
                overflowMode: overflowMode
            )
        }

        static func create(
            value: AdaptyViewConfiguration.Text.Value,
            horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment = `default`.horizontalAlign,
            maxRows: Int? = `default`.maxRows,
            overflowMode: Set<AdaptyViewConfiguration.Text.OverflowMode> = `default`.overflowMode
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

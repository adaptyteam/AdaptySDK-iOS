//
//  VC.Text.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Text {
        let stringId: StringId
        let horizontalAlign: AdaptyUI.HorizontalAlignment
        let maxRows: Int?
        let overflowMode: Set<AdaptyUI.Text.OverflowMode>
        let defaultTextAttributes: TextAttributes?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func text(_ textBlock: AdaptyUI.ViewConfiguration.Text) throws -> AdaptyUI.Text {
        let value: AdaptyUI.Text.Value =
            switch textBlock.stringId {
            case let .basic(stringId):
                .text(richText(
                    stringId: stringId,
                    defaultTextAttributes: textBlock.defaultTextAttributes
                ) ?? .empty)

            case let .product(info):
                if let adaptyProductId = info.adaptyProductId {
                    .productText(AdaptyUI.LazyLocalisedProductText(
                        adaptyProductId: adaptyProductId,
                        suffix: info.suffix,
                        localizer: self,
                        defaultTextAttributes: textBlock.defaultTextAttributes
                    ))
                } else {
                    .selectedProductText(AdaptyUI.LazyLocalisedUnknownProductText(
                        suffix: info.suffix,
                        localizer: self,
                        defaultTextAttributes: textBlock.defaultTextAttributes
                    ))
                }
            }

        return AdaptyUI.Text(
            value: value,
            horizontalAlign: textBlock.horizontalAlign,
            maxRows: textBlock.maxRows,
            overflowMode: textBlock.overflowMode
        )
    }
}

extension AdaptyUI.ViewConfiguration.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case horizontalAlign = "align"
        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stringId = try container.decode(AdaptyUI.ViewConfiguration.StringId.self, forKey: .stringId)
        horizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        maxRows = try container.decodeIfPresent(Int.self, forKey: .maxRows)
        overflowMode =
            if let value = try? container.decode(AdaptyUI.Text.OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([AdaptyUI.Text.OverflowMode].self, forKey: .overflowMode) ?? [])
            }
        let textAttributes = try AdaptyUI.ViewConfiguration.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.isEmpty ? nil : textAttributes
    }
}

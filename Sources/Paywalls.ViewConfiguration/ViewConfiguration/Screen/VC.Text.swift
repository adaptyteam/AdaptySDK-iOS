//
//  VC.Text.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct Text: Sendable, Hashable {
        let stringId: StringId
        let horizontalAlign: AdaptyUICore.HorizontalAlignment
        let maxRows: Int?
        let overflowMode: Set<AdaptyUICore.Text.OverflowMode>
        let defaultTextAttributes: TextAttributes?
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func text(_ textBlock: AdaptyUICore.ViewConfiguration.Text) throws -> AdaptyUICore.Text {
        let value: AdaptyUICore.Text.Value =
            switch textBlock.stringId {
            case let .basic(stringId):
                .text(richText(
                    stringId: stringId,
                    defaultTextAttributes: textBlock.defaultTextAttributes
                ) ?? .empty)

            case let .product(info):
                if let adaptyProductId = info.adaptyProductId {
                    .productText(AdaptyUICore.LazyLocalisedProductText(
                        adaptyProductId: adaptyProductId,
                        suffix: info.suffix,
                        localizer: self,
                        defaultTextAttributes: textBlock.defaultTextAttributes
                    ))
                } else {
                    .selectedProductText(AdaptyUICore.LazyLocalisedUnknownProductText(
                        productGroupId: info.productGroupId ?? AdaptyUICore.ViewConfiguration.StringId.Product.defaultProductGroupId,
                        suffix: info.suffix,
                        localizer: self,
                        defaultTextAttributes: textBlock.defaultTextAttributes
                    ))
                }
            }

        return AdaptyUICore.Text(
            value: value,
            horizontalAlign: textBlock.horizontalAlign,
            maxRows: textBlock.maxRows,
            overflowMode: textBlock.overflowMode
        )
    }
}

extension AdaptyUICore.ViewConfiguration.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case horizontalAlign = "align"
        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stringId = try container.decode(AdaptyUICore.ViewConfiguration.StringId.self, forKey: .stringId)
        horizontalAlign = try container.decodeIfPresent(AdaptyUICore.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        maxRows = try container.decodeIfPresent(Int.self, forKey: .maxRows)
        overflowMode =
            if let value = try? container.decode(AdaptyUICore.Text.OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([AdaptyUICore.Text.OverflowMode].self, forKey: .overflowMode) ?? [])
            }
        let textAttributes = try AdaptyUICore.ViewConfiguration.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.isEmpty ? nil : textAttributes
    }
}

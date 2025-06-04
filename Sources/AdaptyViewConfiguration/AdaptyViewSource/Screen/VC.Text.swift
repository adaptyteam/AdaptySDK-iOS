//
//  VC.Text.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyViewSource {
    struct Text: Sendable, Hashable {
        let stringId: StringId
        let horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment
        let maxRows: Int?
        let overflowMode: Set<AdaptyViewConfiguration.Text.OverflowMode>
        let defaultTextAttributes: TextAttributes?
    }
}

extension AdaptyViewSource.Localizer {
    func text(_ textBlock: AdaptyViewSource.Text) throws -> AdaptyViewConfiguration.Text {
        let value: AdaptyViewConfiguration.Text.Value =
            switch textBlock.stringId {
            case let .basic(stringId):
                .text(richText(
                    stringId: stringId,
                    defaultTextAttributes: textBlock.defaultTextAttributes
                ) ?? .empty)

            case let .product(info):
                if let adaptyProductId = info.adaptyProductId {
                    .productText(AdaptyViewConfiguration.LazyLocalizedProductText(
                        adaptyProductId: adaptyProductId,
                        suffix: info.suffix,
                        localizer: self,
                        defaultTextAttributes: textBlock.defaultTextAttributes
                    ))
                } else {
                    .selectedProductText(AdaptyViewConfiguration.LazyLocalizedUnknownProductText(
                        productGroupId: info.productGroupId ?? AdaptyViewSource.StringId.Product.defaultProductGroupId,
                        suffix: info.suffix,
                        localizer: self,
                        defaultTextAttributes: textBlock.defaultTextAttributes
                    ))
                }
            }

        return AdaptyViewConfiguration.Text(
            value: value,
            horizontalAlign: textBlock.horizontalAlign,
            maxRows: textBlock.maxRows,
            overflowMode: textBlock.overflowMode
        )
    }
}

extension AdaptyViewSource.Text: Codable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case horizontalAlign = "align"
        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stringId = try container.decode(AdaptyViewSource.StringId.self, forKey: .stringId)
        horizontalAlign = try container.decodeIfPresent(AdaptyViewConfiguration.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        maxRows = try container.decodeIfPresent(Int.self, forKey: .maxRows)
        overflowMode =
            if let value = try? container.decode(AdaptyViewConfiguration.Text.OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([AdaptyViewConfiguration.Text.OverflowMode].self, forKey: .overflowMode) ?? [])
            }
        let textAttributes = try AdaptyViewSource.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.isEmpty ? nil : textAttributes
    }

    func encode(to encoder: any Encoder) throws {
        if let defaultTextAttributes = defaultTextAttributes, !defaultTextAttributes.isEmpty {
            try defaultTextAttributes.encode(to: encoder)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stringId, forKey: .stringId)
        if horizontalAlign != .leading {
            try container.encode(horizontalAlign, forKey: .horizontalAlign)
        }
        try container.encodeIfPresent(maxRows, forKey: .maxRows)
        if let first = overflowMode.first {
            if overflowMode.count == 1 {
                try container.encode(first, forKey: .overflowMode)
            } else {
                try container.encode(overflowMode, forKey: .overflowMode)
            }
        }
    }
}

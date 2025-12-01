//
//  Schema.Text.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension Schema {
    struct Text: Sendable, Hashable {
        let stringId: StringId
        let horizontalAlign: HorizontalAlignment
        let maxRows: Int?
        let overflowMode: Set<OverflowMode>
        let defaultTextAttributes: TextAttributes?
    }
}

extension Schema.Localizer {
    func text(_ textBlock: Schema.Text) -> VC.Text {
        let value: VC.Text.Value =
            switch textBlock.stringId {
            case let .basic(stringId):
                .text(richText(
                    stringId: stringId,
                    defaultTextAttributes: textBlock.defaultTextAttributes
                ) ?? .empty)

            case let .product(info):
                if let adaptyProductId = info.adaptyProductId {
                    .productText(VC.LazyLocalizedProductText(
                        adaptyProductId: adaptyProductId,
                        suffix: info.suffix,
                        localizer: self,
                        defaultTextAttributes: textBlock.defaultTextAttributes
                    ))
                } else {
                    .selectedProductText(VC.LazyLocalizedUnknownProductText(
                        productGroupId: info.productGroupId ?? Schema.StringId.Product.defaultProductGroupId,
                        suffix: info.suffix,
                        localizer: self,
                        defaultTextAttributes: textBlock.defaultTextAttributes
                    ))
                }
            }

        return .init(
            value: value,
            horizontalAlign: textBlock.horizontalAlign,
            maxRows: textBlock.maxRows,
            overflowMode: textBlock.overflowMode
        )
    }
}

extension Schema.Text: Codable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case horizontalAlign = "align"
        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stringId = try container.decode(Schema.StringId.self, forKey: .stringId)
        horizontalAlign = try container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        maxRows = try container.decodeIfPresent(Int.self, forKey: .maxRows)
        overflowMode =
            if let value = try? container.decode(OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([OverflowMode].self, forKey: .overflowMode) ?? [])
            }
        let textAttributes = try Schema.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.nonEmptyOrNil
    }

    func encode(to encoder: any Encoder) throws {
        if let defaultTextAttributes = defaultTextAttributes.nonEmptyOrNil {
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

//
//  Schema.TextAttributes.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 08.02.2026.
//

import Foundation

extension Schema {
    typealias TextAttributes = VC.TextAttributes
}

extension Schema.TextAttributes? {
    var nonEmptyOrNil: Self {
        self?.nonEmptyOrNil
    }
}

extension Schema.TextAttributes: Decodable {
    enum CodingKeys: String, CodingKey {
        case size
        case fontAssetId = "font"
        case legacyColor = "color"
        case color = "text_color"
        case imageTintColor = "tint"
        case legacyBackground = "background"
        case background = "text_background"
        case strike
        case underline
        case letterSpacing = "letter_spacing"
        case lineHeight = "line_height"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fontAssetId = try container.decodeIfPresent(VC.AssetReference.self, forKeys: .fontAssetId)

        // `legacyBackground` conflicts with `Schema.ElementProperties.background`, which
        // uses the same JSON key for an array of aligned elements. Decode it here only
        // when the value is not an array.
        let legacyBackground = {
            guard !container.isArray(.legacyBackground) else {
                return Schema.AssetReference?.none
            }
            return try container.decodeIfPresent(Schema.AssetReference.self, forKeys: .legacyBackground)
        }
        let legacyColor = { try container.decodeIfPresent(Schema.AssetReference.self, forKeys: .legacyColor) }

        try self.init(
            fontAssetId: fontAssetId?.isColor ?? true ? nil : fontAssetId,
            size: container.decodeIfPresent(Double.self, forKeys: .size),
            color: container.decodeIfPresent(Schema.AssetReference.self, forKeys: .color) ?? legacyColor(),
            imageTintColor: container.decodeIfPresent(Schema.AssetReference.self, forKeys: .imageTintColor),
            background: container.decodeIfPresent(Schema.AssetReference.self, forKeys: .background) ?? legacyBackground(),
            strike: container.decodeIfPresent(Bool.self, forKeys: .strike),
            underline: container.decodeIfPresent(Bool.self, forKeys: .underline),
            letterSpacing: container.decodeIfPresent(Double.self, forKey: .letterSpacing),
            lineHeight: container.decodeIfPresent(Double.self, forKey: .lineHeight)
        )
    }
}

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

extension Schema.TextAttributes: Codable {
    enum CodingKeys: String, CodingKey {
        case size
        case fontAssetId = "font"
        case txtColor = "color"
        case imageTintColor = "tint"
        case background
        case strike
        case underline
        case letterSpacing = "letter_spacing"
        case lineHeight = "line_height"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fontAssetId = try container.decodeIfPresent(VC.AssetReference.self, forKeys: .fontAssetId)
        try self.init(
            fontAssetId: fontAssetId?.isColor ?? true ? nil : fontAssetId,
            size: container.decodeIfPresent(Double.self, forKeys: .size),
            txtColor: container.decodeIfPresent(Schema.AssetReference.self, forKeys: .txtColor),
            imageTintColor: container.decodeIfPresent(Schema.AssetReference.self, forKeys: .imageTintColor),
            background: container.decodeIfPresent(Schema.AssetReference.self, forKeys: .background),
            strike: container.decodeIfPresent(Bool.self, forKeys: .strike),
            underline: container.decodeIfPresent(Bool.self, forKeys: .underline),
            letterSpacing: container.decodeIfPresent(Double.self, forKey: .letterSpacing),
            lineHeight: container.decodeIfPresent(Double.self, forKey: .lineHeight)
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fontAssetId, forKey: .fontAssetId)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(txtColor, forKey: .txtColor)
        try container.encodeIfPresent(imageTintColor, forKey: .imageTintColor)
        try container.encodeIfPresent(background, forKey: .background)
        try container.encodeIfPresent(strike, forKey: .strike)
        try container.encodeIfPresent(underline, forKey: .underline)
        try container.encodeIfPresent(letterSpacing, forKey: .letterSpacing)
        try container.encodeIfPresent(lineHeight, forKey: .lineHeight)
    }
}


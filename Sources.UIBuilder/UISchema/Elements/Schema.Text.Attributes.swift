//
//  Schema.Text.Attributes.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 08.02.2026.
//

import Foundation

extension Schema.Text.Attributes? {
    var nonEmptyOrNil: Self {
        self?.nonEmptyOrNil
    }
}

extension Schema.Text.Attributes: Codable {
    enum CodingKeys: String, CodingKey {
        case size
        case fontAssetId = "font"
        case txtColor = "color"
        case imageTintColor = "tint"
        case background
        case strike
        case underline
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            fontAssetId: container.decodeIfPresent(VC.AssetIdentifier.self, forKeys: .fontAssetId),
            size: container.decodeIfPresent(Double.self, forKeys: .size),
            txtColor: container.decodeIfPresent(Schema.AssetReference.self, forKeys: .txtColor),
            imageTintColor: container.decodeIfPresent(Schema.AssetReference.self, forKeys: .imageTintColor),
            background: container.decodeIfPresent(Schema.AssetReference.self, forKeys: .background),
            strike: container.decodeIfPresent(Bool.self, forKeys: .strike),
            underline: container.decodeIfPresent(Bool.self, forKeys: .underline)
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fontAssetId, forKey: .fontAssetId)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(txtColor, forKey: .txtColor)
        try container.encodeIfPresent(imageTintColor, forKey: .imageTintColor)
        try container.encodeIfPresent(background, forKey: .background)
        try container.encodeIfPresent(strike, forKey: .strike)
        try container.encodeIfPresent(underline, forKey: .underline)
    }
}

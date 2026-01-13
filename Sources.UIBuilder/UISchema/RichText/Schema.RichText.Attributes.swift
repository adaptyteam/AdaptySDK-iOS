//
//  Schema.RichText.Attributes.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.12.2025.
//

import Foundation

extension Schema.RichText {
    typealias Attributes = VC.RichText.Attributes
}

extension Schema.RichText.Attributes? {
    var nonEmptyOrNil: Self { self?.nonEmptyOrNil }
}

extension Schema.RichText.Attributes: Codable {
    enum CodingKeys: String, CodingKey {
        case size
        case font
        case txtColor = "color"
        case imageTintColor = "tint"
        case background
        case strike
        case underline
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            font: container.decodeIfPresent(Schema.AssetReference.self, forKeys: .font),
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
        try container.encodeIfPresent(font, forKey: .font)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(txtColor, forKey: .txtColor)
        try container.encodeIfPresent(imageTintColor, forKey: .imageTintColor)
        try container.encodeIfPresent(background, forKey: .background)
        try container.encodeIfPresent(strike, forKey: .strike)
        try container.encodeIfPresent(underline, forKey: .underline)
    }
}

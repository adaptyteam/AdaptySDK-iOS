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
    var nonEmptyOrNil: Self {
        self?.nonEmptyOrNil
    }
}

extension Schema.RichText.Attributes: Decodable {
    enum CodingKeys: String, CodingKey {
        case size
        case fontAssetId = "font"
        case txtColor = "color"
        case imageTintColor = "tint"
        case background
        case strike
        case underline
        case letterSpacing = "letter_spacing"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            fontAssetId: container.decodeIfPresent(Schema.AssetIdentifier.self, forKeys: .fontAssetId),
            size: container.decodeIfPresent(Double.self, forKeys: .size),
            txtColor: container.decodeIfPresent(Schema.AssetIdentifierOrValue.self, forKeys: .txtColor),
            imageTintColor: container.decodeIfPresent(Schema.AssetIdentifierOrValue.self, forKeys: .imageTintColor),
            background: container.decodeIfPresent(Schema.AssetIdentifierOrValue.self, forKeys: .background),
            strike: container.decodeIfPresent(Bool.self, forKeys: .strike),
            underline: container.decodeIfPresent(Bool.self, forKeys: .underline),
            letterSpacing: container.decodeIfPresent(Double.self, forKey: .letterSpacing)
        )
    }
}

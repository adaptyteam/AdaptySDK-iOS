//
//  Schema.Image.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension Schema {
    typealias Image = VC.Image
}

extension Schema.Image: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .image(self, properties)
    }
}

extension Schema.Image: Decodable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case tintAssetId = "tint"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let asset = try container.decode(Schema.AssetReference.self, forKey: .assetId)
        if asset.isColor {
            throw DecodingError.dataCorruptedError(
                forKey: .assetId,
                in: container,
                debugDescription: "Image asset_id should not be a color"
            )
        }
        try self.init(
            asset: asset,
            aspect: container.decodeIfPresent(Schema.AspectRatio.self, forKey: .aspect) ?? .default,
            tint: container.decodeIfPresent(Schema.AssetReference.self, forKey: .tintAssetId)
        )
    }
}

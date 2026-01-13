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

extension Schema.Image: Decodable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case tintAssetId = "tint"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            asset: container.decode(Schema.AssetReference.self, forKey: .assetId),
            aspect: container.decodeIfPresent(Schema.AspectRatio.self, forKey: .aspect) ?? Schema.AspectRatio.default,
            tint: container.decodeIfPresent(Schema.AssetReference.self, forKey: .tintAssetId)
        )
    }
}

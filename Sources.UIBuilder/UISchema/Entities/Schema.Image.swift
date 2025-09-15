//
//  Schema.Image.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension Schema {
    struct Image: Sendable, Hashable {
        let assetId: String
        let aspect: AdaptyViewConfiguration.AspectRatio
        let tintAssetId: String?
    }
}

extension Schema.Localizer {
    func image(_ from: Schema.Image) throws -> AdaptyViewConfiguration.Image {
        try .init(
            asset: imageData(from.assetId),
            aspect: from.aspect,
            tint: from.tintAssetId.flatMap { try? filling($0) }
        )
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
        assetId = try container.decode(String.self, forKey: .assetId)
        aspect = try container.decodeIfPresent(AdaptyViewConfiguration.AspectRatio.self, forKey: .aspect) ?? AdaptyViewConfiguration.Image.defaultAspectRatio
        tintAssetId = try container.decodeIfPresent(String.self, forKey: .tintAssetId)
    }
}

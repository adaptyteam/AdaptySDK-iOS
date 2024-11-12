//
//  VC.Image.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyViewSource {
    struct Image: Sendable, Hashable {
        let assetId: String
        let aspect: AdaptyViewConfiguration.AspectRatio
        let tintAssetId: String?
    }
}

extension AdaptyViewSource.Localizer {
    func image(_ from: AdaptyViewSource.Image) throws -> AdaptyViewConfiguration.Image {
        try .init(
            asset: imageData(from.assetId),
            aspect: from.aspect,
            tint: from.tintAssetId.flatMap { try? filling($0) }
        )
    }
}

extension AdaptyViewSource.Image: Decodable {
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

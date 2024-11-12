//
//  VC.Image.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct Image: Sendable, Hashable {
        let assetId: String
        let aspect: AdaptyUICore.AspectRatio
        let tintAssetId: String?
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func image(_ from: AdaptyUICore.ViewConfiguration.Image) throws -> AdaptyUICore.Image {
        try .init(
            asset: imageData(from.assetId),
            aspect: from.aspect,
            tint: from.tintAssetId.flatMap { try? filling($0) }
        )
    }
}

extension AdaptyUICore.ViewConfiguration.Image: Decodable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case tintAssetId = "tint"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assetId = try container.decode(String.self, forKey: .assetId)
        aspect = try container.decodeIfPresent(AdaptyUICore.AspectRatio.self, forKey: .aspect) ?? AdaptyUICore.Image.defaultAspectRatio
        tintAssetId = try container.decodeIfPresent(String.self, forKey: .tintAssetId)
    }
}

//
//  VC.Image.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Image: Hashable, Sendable {
        let assetId: String
        let aspect: AdaptyUI.AspectRatio
        let tintAssetId: String?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func image(_ from: AdaptyUI.ViewConfiguration.Image) throws -> AdaptyUI.Image {
        try .init(
            asset: imageData(from.assetId),
            aspect: from.aspect,
            tint: from.tintAssetId.flatMap { try? filling($0) }
        )
    }
}

extension AdaptyUI.ViewConfiguration.Image: Decodable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case tintAssetId = "tint"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assetId = try container.decode(String.self, forKey: .assetId)
        aspect = try container.decodeIfPresent(AdaptyUI.AspectRatio.self, forKey: .aspect) ?? AdaptyUI.Image.defaultAspectRatio
        tintAssetId = try container.decodeIfPresent(String.self, forKey: .tintAssetId)
    }
}

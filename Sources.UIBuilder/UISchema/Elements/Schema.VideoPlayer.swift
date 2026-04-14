//
//  Schema.VideoPlayer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension Schema {
    typealias VideoPlayer = VC.VideoPlayer
}

extension Schema.VideoPlayer: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .video(self, properties)
    }
}

extension Schema.VideoPlayer: Decodable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case loop
        case actions = "action"
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
            aspect: container.decodeIfPresent(Schema.AspectRatio.self, forKey: .aspect)
                ?? .default,
            loop: container.decodeIfPresent(Bool.self, forKey: .loop)
                ?? true,
            actions: container.decodeIfPresentActions(forKey: .actions) ?? []
        )
    }
}

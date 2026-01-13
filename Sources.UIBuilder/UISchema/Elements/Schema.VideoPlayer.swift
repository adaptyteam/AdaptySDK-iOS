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

extension Schema.VideoPlayer: Codable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case loop
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            asset: container.decode(Schema.AssetReference.self, forKey: .assetId),
            aspect: container.decodeIfPresent(Schema.AspectRatio.self, forKey: .aspect)
                ?? .default,
            loop: container.decodeIfPresent(Bool.self, forKey: .loop)
                ?? true
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(asset, forKey: .assetId)
        if aspect != .default {
            try container.encode(aspect, forKey: .aspect)
        }
        if loop {
            try container.encode(loop, forKey: .loop)
        }
    }
}

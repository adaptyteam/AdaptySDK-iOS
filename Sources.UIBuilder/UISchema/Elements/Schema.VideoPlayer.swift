//
//  Schema.VideoPlayer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension Schema {
    struct VideoPlayer: Hashable, Sendable {
        let assetId: String
        let aspect: AspectRatio
        let loop: Bool
    }
}

extension Schema.Localizer {
    func videoPlayer(_ from: Schema.VideoPlayer) throws -> VC.VideoPlayer {
        try .init(
            asset: videoData(from.assetId),
            aspect: from.aspect,
            loop: from.loop
        )
    }
}

extension Schema.VideoPlayer: Codable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case loop
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            assetId: container.decode(String.self, forKey: .assetId),
            aspect: container.decodeIfPresent(Schema.AspectRatio.self, forKey: .aspect)
                ?? .default,
            loop: container.decodeIfPresent(Bool.self, forKey: .loop)
                ?? true
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(assetId, forKey: .assetId)
        if aspect != .default {
            try container.encode(aspect, forKey: .aspect)
        }
        if loop {
            try container.encode(loop, forKey: .loop)
        }
    }
}

//
//  VC.VideoPlayer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension AdaptyViewSource {
    struct VideoPlayer: Hashable, Sendable {
        let assetId: String
        let aspect: AdaptyViewConfiguration.AspectRatio
        let loop: Bool
    }
}

extension AdaptyViewSource.Localizer {
    func videoPlayer(_ from: AdaptyViewSource.VideoPlayer) throws -> AdaptyViewConfiguration.VideoPlayer {
        try .init(
            asset: videoData(from.assetId),
            aspect: from.aspect,
            loop: from.loop
        )
    }
}

extension AdaptyViewSource.VideoPlayer: Decodable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case loop
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assetId = try container.decode(String.self, forKey: .assetId)
        aspect = try container.decodeIfPresent(AdaptyViewConfiguration.AspectRatio.self, forKey: .aspect) ?? AdaptyViewConfiguration.VideoPlayer.defaultAspectRatio
        loop = try container.decodeIfPresent(Bool.self, forKey: .loop) ?? true
    }
}

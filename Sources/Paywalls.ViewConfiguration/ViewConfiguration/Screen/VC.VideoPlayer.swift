//
//  VC.VideoPlayer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct VideoPlayer: Hashable, Sendable {
        let assetId: String
        let aspect: AdaptyUICore.AspectRatio
        let loop: Bool
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func videoPlayer(_ from: AdaptyUICore.ViewConfiguration.VideoPlayer) throws -> AdaptyUICore.VideoPlayer {
        try .init(
            asset: videoData(from.assetId),
            aspect: from.aspect,
            loop: from.loop
        )
    }
}

extension AdaptyUICore.ViewConfiguration.VideoPlayer: Decodable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case loop
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assetId = try container.decode(String.self, forKey: .assetId)
        aspect = try container.decodeIfPresent(AdaptyUICore.AspectRatio.self, forKey: .aspect) ?? AdaptyUICore.VideoPlayer.defaultAspectRatio
        loop = try container.decodeIfPresent(Bool.self, forKey: .loop) ?? true
    }
}

//
//  VC.VideoPlayer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct VideoPlayer: Hashable, Sendable {
        let assetId: String
        let aspect: AdaptyUI.AspectRatio
        let loop: Bool
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func videoPlayer(_ from: AdaptyUI.ViewConfiguration.VideoPlayer) throws -> AdaptyUI.VideoPlayer {
        try .init(
            asset: videoData(from.assetId),
            aspect: from.aspect,
            loop: from.loop
        )
    }
}

extension AdaptyUI.ViewConfiguration.VideoPlayer: Decodable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case loop
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assetId = try container.decode(String.self, forKey: .assetId)
        aspect = try container.decodeIfPresent(AdaptyUI.AspectRatio.self, forKey: .aspect) ?? AdaptyUI.VideoPlayer.defaultAspectRatio
        loop = try container.decodeIfPresent(Bool.self, forKey: .loop) ?? true
    }
}

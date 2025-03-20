//
//  VC.Animation.AssetIdValue.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.03.2025.
//

import Foundation

extension AdaptyViewSource.Animation {
    typealias Interpolator = AdaptyViewConfiguration.Animation.Interpolator

    struct AssetIdValue: Sendable {
        package let interpolator: Interpolator
        package let startAssetId: String
        package let endAssetId: String
    }
}

extension AdaptyViewSource.Localizer {
    func animationFillingValue(_ from: AdaptyViewSource.Animation.AssetIdValue) throws -> AdaptyViewConfiguration.Animation.FillingValue {
        try .init(
            interpolator: from.interpolator,
            start: filling(from.startAssetId),
            end: filling(from.endAssetId)
        )
    }
}

extension AdaptyViewSource.Animation.AssetIdValue: Codable {
    enum CodingKeys: String, CodingKey {
        case startAssetId = "start"
        case endAssetId = "end"
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startAssetId = try container.decode(String.self, forKey: .startAssetId)
        endAssetId = try container.decode(String.self, forKey: .endAssetId)
        interpolator = try (container.decodeIfPresent(AdaptyViewSource.Animation.Interpolator.self, forKey: .interpolator)) ?? .default
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startAssetId, forKey: .startAssetId)
        try container.encode(endAssetId, forKey: .endAssetId)
        if interpolator != .default {
            try container.encode(interpolator, forKey: .interpolator)
        }
    }
}

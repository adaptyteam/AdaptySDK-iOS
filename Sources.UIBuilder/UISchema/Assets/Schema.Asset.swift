//
//  Schema.Asset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension Schema {
    enum Asset: Sendable {
        case asset(VC.Asset)
        case unknown(type: String, fallbackAssetId: String?)
    }
}

extension Schema.Asset: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case value
        case customId = "custom_id"
        case fallbackAssetId = "fallback_asset_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case VC.Color.assetType:
            self = try .asset(.solidColor(.init(
                customId: container.decodeIfPresent(String.self, forKey: .customId),
                data: container.decode(Schema.Color.self, forKey: .value).data
            )))
        case let type where Schema.ColorGradient.assetType(type):
            self = try .asset(.colorGradient(Schema.ColorGradient(from: decoder)))
        case VC.Font.assetType:
            self = try .asset(.font(Schema.Font(from: decoder)))
        case VC.ImageData.assetType:
            self = try .asset(.image(Schema.ImageData(from: decoder)))
        case VC.VideoData.assetType:
            self = try .asset(.video(Schema.VideoData(from: decoder)))
        default:
            self = try .unknown(type: type, fallbackAssetId: container.decodeIfPresent(String.self, forKey: .fallbackAssetId))
        }
    }
}


//
//  Schema.VideoData.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema {
    typealias VideoData = VC.VideoData
}

extension Schema.VideoData {
    static let assetType = "video"

    static func assetType(_ type: String) -> Bool {
        type == assetType
    }
}

extension Schema.VideoData: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case url
        case image
        case customId = "custom_id"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            customId: container.decodeIfPresent(String.self, forKey: .customId),
            url: container.decode(URL.self, forKey: .url),
            image: container.decode(Schema.ImageData.self, forKey: .image)
        )
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(Self.assetType, forKey: .type)

        try container.encodeIfPresent(customId, forKey: .customId)
        try container.encode(url, forKey: .url)
        try container.encode(image, forKey: .image)
    }
}

//
//  VideoData.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    struct VideoData: CustomAsset, Sendable {
        package let customId: String?
        package let url: URL
        package let image: ImageData
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.VideoData {
    static func create(customId: String? = nil, url: URL, image: AdaptyViewConfiguration.ImageData) -> Self {
        .init(customId: customId, url: url, image: image)
    }
}
#endif

extension AdaptyViewConfiguration.VideoData: Hashable {}

extension AdaptyViewConfiguration.VideoData: Codable {
    static let assetType = "video"

    private enum CodingKeys: String, CodingKey {
        case type
        case url
        case image
        case customId = "custom_id"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        customId = try container.decodeIfPresent(String.self, forKey: .customId)
        url = try container.decode(URL.self, forKey: .url)
        image = try container.decode(AdaptyViewConfiguration.ImageData.self, forKey: .image)
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(Self.assetType, forKey: .type)

        try container.encodeIfPresent(customId, forKey: .customId)
        try container.encode(url, forKey: .url)
        try container.encode(image, forKey: .image)
    }
}

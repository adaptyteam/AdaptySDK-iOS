//
//  VideoData.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    enum VideoData: Sendable {
        case url(URL, image: ImageData)
        case custom(videoId: String, imageId: String)

        var image: ImageData {
            switch self {
            case let .url(_, image):
                image
            case let .custom(_, value):
                .custom(value)
            }
        }
    }
}

extension AdaptyViewConfiguration.VideoData: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .url(url, img):
            hasher.combine(1)
            hasher.combine(url)
            hasher.combine(img)
        case let .custom(videoId, imageId):
            hasher.combine(2)
            hasher.combine(videoId)
            hasher.combine(imageId)
        }
    }
}

extension AdaptyViewConfiguration.VideoData: Codable {
    static let assetType = "video"

    private enum CodingKeys: String, CodingKey {
        case type
        case url
        case image
        case custom
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let videoId = try container.decodeIfPresent(String.self, forKey: .custom) {
            guard container.contains(.image) else {
                self = .custom(videoId: videoId, imageId: videoId)
                return
            }
            let image = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .image)
            let id = try image.decode(String.self, forKey: .custom)
            self = .custom(videoId: videoId, imageId: id)
            return
        }

        self = try .url(
            container.decode(URL.self, forKey: .url),
            image: container.decode(AdaptyViewConfiguration.ImageData.self, forKey: .image)
        )
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(Self.assetType, forKey: .type)

        switch self {
        case let .url(url, img):
            try container.encode(url, forKey: .url)
            try container.encode(img, forKey: .image)
        case let .custom(videoId, imageId):
            try container.encode(videoId, forKey: .custom)
            if videoId != imageId {
                var image = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .image)
                try image.encode(imageId, forKey: .custom)
            }
        }
    }
}

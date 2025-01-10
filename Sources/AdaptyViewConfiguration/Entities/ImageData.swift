//
//  ImageData.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package extension AdaptyViewConfiguration {
    enum ImageData: Sendable {
        case raster(Data)
        case url(URL, previewRaster: Data?)
        case custom(String)
    }
}

extension AdaptyViewConfiguration.ImageData: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .raster(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .url(url, previewRaster: value):
            hasher.combine(2)
            hasher.combine(url)
            hasher.combine(value)
        case let .custom(value):
            hasher.combine(3)
            hasher.combine(value)
        }
    }
}

extension AdaptyViewConfiguration.ImageData: Codable {
    static let assetType = "image"

    private enum CodingKeys: String, CodingKey {
        case type
        case data = "value"
        case url
        case previewData = "preview_value"
        case custom
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let data = try container.decodeIfPresent(Data.self, forKey: .data) {
            self = .raster(data)
            return
        }

        if let id = try container.decodeIfPresent(String.self, forKey: .custom) {
            self = .custom(id)
            return
        }

        self = try .url(
            container.decode(URL.self, forKey: .url),
            previewRaster: container.decodeIfPresent(Data.self, forKey: .previewData)
        )
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(Self.assetType, forKey: .type)
        switch self {
        case let .raster(value):
            try container.encode(value, forKey: .data)
        case let .url(url, previewRaster):
            try container.encode(url, forKey: .url)
            try container.encodeIfPresent(previewRaster, forKey: .previewData)
        case let .custom(value):
            try container.encode(value, forKey: .custom)
        }
    }
}

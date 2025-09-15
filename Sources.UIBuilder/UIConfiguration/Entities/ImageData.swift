//
//  ImageData.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package extension AdaptyUIConfiguration {
    enum ImageData: CustomAsset, Sendable {
        case raster(customId: String?, Data)
        case url(customId: String?, URL, previewRaster: Data?)

        package var customId: String? {
            switch self {
            case let .raster(customId, _),
                 let .url(customId, _, _):
                customId
            }
        }

        var url: URL? {
            switch self {
            case let .url(_, url, _):
                url
            default:
                nil
            }
        }
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.ImageData {
    static func create(customId: String? = nil, rasterData: Data) -> Self {
        .raster(customId: customId, rasterData)
    }

    static func create(customId: String? = nil, url: URL, previewRasterData: Data? = nil) -> Self {
        .url(customId: customId, url, previewRaster: previewRasterData)
    }
}
#endif

extension AdaptyUIConfiguration.ImageData: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .raster(customId, value):
            hasher.combine(1)
            hasher.combine(customId)
            hasher.combine(value)
        case let .url(customId, url, previewRaster: value):
            hasher.combine(2)
            hasher.combine(customId)
            hasher.combine(url)
            hasher.combine(value)
        }
    }
}

extension AdaptyUIConfiguration.ImageData: Codable {
    static let assetType = "image"

    private enum CodingKeys: String, CodingKey {
        case type
        case data = "value"
        case url
        case previewData = "preview_value"
        case customId = "custom_id"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let customId = try container.decodeIfPresent(String.self, forKey: .customId)
        if let data = try container.decodeIfPresent(Data.self, forKey: .data) {
            self = .raster(customId: customId, data)
            return
        }

        self = try .url(
            customId: customId,
            container.decode(URL.self, forKey: .url),
            previewRaster: container.decodeIfPresent(Data.self, forKey: .previewData)
        )
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(Self.assetType, forKey: .type)
        switch self {
        case let .raster(customId, value):
            try container.encodeIfPresent(customId, forKey: .customId)
            try container.encode(value, forKey: .data)
        case let .url(customId, url, previewRaster):
            try container.encodeIfPresent(customId, forKey: .customId)
            try container.encode(url, forKey: .url)
            try container.encodeIfPresent(previewRaster, forKey: .previewData)
        }
    }
}

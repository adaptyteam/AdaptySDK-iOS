//
//  ImageData.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUI {
    package enum ImageData: Sendable {
        case raster(Data)
        case url(URL, previewRaster: Data?)
        case resorces(String)
    }
}

extension AdaptyUI.ImageData: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .raster(value):
            hasher.combine(value)
        case let .url(url, previewRaster: value):
            hasher.combine(url)
            hasher.combine(value)
        case let .resorces(value):
            hasher.combine(value)
        }
    }
}

extension AdaptyUI.ImageData: Decodable {
    enum CodingKeys: String, CodingKey {
        case data = "value"
        case url
        case previewData = "preview_value"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let data = try container.decodeIfPresent(Data.self, forKey: .data) {
            self = .raster(data)
            return
        }

        self = try .url(
            container.decode(URL.self, forKey: .url),
            previewRaster: container.decodeIfPresent(Data.self, forKey: .previewData)
        )
    }
}

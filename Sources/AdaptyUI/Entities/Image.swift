//
//  Asset.Image.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUI {
    public enum Image {
        case raster(Data)
//        case vector(Data)
        case url(URL, previewRaster: Data?)
    }
}

extension AdaptyUI.Image: Decodable {
    enum CodingKeys: String, CodingKey {
        case data = "value"
        case url
        case previewData = "preview_value"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let data = try container.decodeIfPresent(Data.self, forKey: .data) {
            self = .raster(data)
            return
        }

        self = .url(
            try container.decode(URL.self, forKey: .url),
            previewRaster: try container.decodeIfPresent(Data.self, forKey: .previewData)
        )
    }
}

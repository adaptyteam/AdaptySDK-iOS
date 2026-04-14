//
//  Schema.ImageData.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema {
    typealias ImageData = VC.ImageData
}

extension Schema.ImageData {
    static let assetType = "image"

    static func assetType(_ type: String) -> Bool {
        type == assetType
    }
}

extension Schema.ImageData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case data = "value"
        case url
        case previewData = "preview_value"
        case customId = "custom_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let customId = try container.decodeIfPresent(String.self, forKey: .customId)

        if let base64EncodedData = try container.decodeIfPresent(String.self, forKey: .data),
           base64EncodedData.isNotEmpty
        {
            guard let data = Data(base64Encoded: base64EncodedData) else {
                throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath + [CodingKeys.data], debugDescription: "must base64 encoded data"))
            }
            self = .raster(customId: customId, data)
            return
        }

        var previewRaster: Data? = nil

        if let base64EncodedData = try container.decodeIfPresent(String.self, forKey: .previewData),
           base64EncodedData.isNotEmpty
        {
            guard let data = Data(base64Encoded: base64EncodedData) else {
                throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath + [CodingKeys.previewData], debugDescription: "must base64 encoded data"))
            }
            previewRaster = data
        }

        self = try .url(
            customId: customId,
            container.decode(URL.self, forKey: .url),
            previewRaster: previewRaster
        )
    }
}

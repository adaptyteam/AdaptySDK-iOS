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

extension Schema.VideoData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case url
        case image
        case customId = "custom_id"
        case verticalResolution = "v_res"
        case horizontalResolution = "h_res"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            customId: container.decodeIfPresent(String.self, forKey: .customId),
            url: container.decode(URL.self, forKey: .url),
            image: container.decode(Schema.ImageData.self, forKey: .image),
            verticalResolution: container.decodeIfPresent(Int.self, forKey: .verticalResolution) ?? 0,
            horizontalResolution: container.decodeIfPresent(Int.self, forKey: .horizontalResolution) ?? 0
        )
    }
}


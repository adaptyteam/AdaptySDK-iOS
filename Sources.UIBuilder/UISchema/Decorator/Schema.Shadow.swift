//
//  Schema.Shadow.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension Schema {
    typealias Shadow = VC.Shadow
}

extension Schema.Shadow {
    static let `default` = (
        blurRadius: 0.0,
        offset: Schema.Offset.zero
    )
}

extension Schema.Shadow: Decodable {
    enum CodingKeys: String, CodingKey {
        case colorAssetId = "color"
        case blurRadius = "blur_radius"
        case offset
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            filling: container.decode(Schema.AssetReference.self, forKey: .colorAssetId),
            blurRadius: container.decodeIfPresent(Double.self, forKey: .blurRadius)
                ?? Schema.Shadow.default.blurRadius,
            offset: container.decodeIfPresent(VC.Offset.self, forKey: .offset)
                ?? Schema.Shadow.default.offset
        )
    }
}

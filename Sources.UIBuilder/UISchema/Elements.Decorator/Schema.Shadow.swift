//
//  Schema.Shadow.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension Schema {
    struct Shadow: Sendable, Hashable {
        let colorAssetId: String
        let blurRadius: Double
        let offset: Offset
    }
}

extension Schema.Shadow {
    static let `default` = (
        blurRadius: 0.0,
        offset: Schema.Offset.zero
    )
}

extension Schema.Localizer {
    func shadow(_ from: Schema.Shadow) throws -> VC.Shadow {
        .init(
            filling: (try? filling(from.colorAssetId)) ?? .same(Schema.Filling.transparent),
            blurRadius: from.blurRadius,
            offset: from.offset
        )
    }
}

extension Schema.Shadow: Decodable {
    enum CodingKeys: String, CodingKey {
        case colorAssetId = "color"
        case blurRadius = "blur_radius"
        case offset
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            colorAssetId: container.decode(String.self, forKey: .colorAssetId),
            blurRadius: container.decodeIfPresent(Double.self, forKey: .blurRadius)
                ?? Schema.Shadow.default.blurRadius,
            offset: container.decodeIfPresent(VC.Offset.self, forKey: .offset)
                ?? Schema.Shadow.default.offset
        )
    }
}

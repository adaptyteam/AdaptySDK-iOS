//
//  Schema.Animation.BackgroundParameters.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 27.10.2026.
//

import Foundation

extension Schema.Animation.BackgroundParameters: Decodable {
    enum CodingKeys: String, CodingKey {
        case color
        case targetId = "target_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            color: container.decode(Schema.Animation.Range<Schema.AssetReference>.self, forKey: .color),
            targetId: container.decodeIfPresent(Int.self, forKey: .targetId) ?? 0
        )
    }
}

//
//  Schema.RangeTextFormat.Item.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension Schema.RangeTextFormat {
    struct Item: Sendable, Hashable {
        let from: Double
        let stringId: String
    }
}

extension Schema.RangeTextFormat.Item: Codable {
    enum CodingKeys: String, CodingKey {
        case from
        case stringId = "string_id"
    }
}

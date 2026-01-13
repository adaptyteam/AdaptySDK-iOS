//
//  Schema.StringReference.Product.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.12.2025.
//

import Foundation

extension Schema.StringReference.Product: Codable {
    static let typeValue = "product"
    enum CodingKeys: String, CodingKey {
        case type
        case productGroupId = "group_id"
        case adaptyProductId = "id"
        case suffix
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        guard type == Self.typeValue else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "is not equeal \"\(Self.typeValue)\" "))
        }

        adaptyProductId = try container.decodeIfPresent(String.self, forKey: .adaptyProductId)
        productGroupId = try container.decodeIfPresent(String.self, forKey: .productGroupId)
        suffix = try container.decodeIfPresent(String.self, forKey: .suffix)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.typeValue, forKey: .type)
        try container.encodeIfPresent(productGroupId, forKey: .productGroupId)
        try container.encodeIfPresent(adaptyProductId, forKey: .adaptyProductId)
        try container.encodeIfPresent(suffix, forKey: .suffix)
    }
}

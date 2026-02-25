//
//  Schema.StringReference.Product.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.12.2025.
//

import Foundation

extension Schema.StringReference.Product: Codable {
    enum CodingKeys: String, CodingKey {
        case product
        case suffix
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard container.contains(.product) else {
            self = try Self.legacyDecode(from: decoder)
            return
        }

        if let productId = try? container.decode(String.self, forKey: .product) {
            self = try .id(
                productId,
                sufix: container.decodeIfPresent(String.self, forKey: .suffix)
            )
        } else {
            self = try .variable(
                container.decode(Schema.Variable.self, forKey: .product),
                sufix: container.decodeIfPresent(String.self, forKey: .suffix)
            )
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .id(let productId, let suffix):
            try container.encode(productId, forKey: .product)
            try container.encodeIfPresent(suffix, forKey: .suffix)
        case .variable(let variable, let suffix):
            try container.encode(variable, forKey: .product)
            try container.encodeIfPresent(suffix, forKey: .suffix)
        }
    }
}

private extension Schema.StringReference.Product {
    enum LegacyCodingKeys: String, CodingKey {
        case type
        case productGroupId = "group_id"
        case adaptyProductId = "id"
        case suffix
    }

    static func legacyDecode(from decoder: Decoder) throws -> Self {
        let container = try decoder.container(keyedBy: LegacyCodingKeys.self)

        let suffix = try container.decodeIfPresent(String.self, forKey: .suffix)

        guard !container.contains(.adaptyProductId) else {
            return try .id(
                container.decode(String.self, forKey: .adaptyProductId),
                sufix: suffix
            )
        }

        guard !container.contains(.productGroupId) else {
            return try .variable(
                .init(
                    path: ["Legacy", "productGroup", container.decode(String.self, forKey: .productGroupId)],
                    setter: nil,
                    scope: .global,
                    converter: nil
                ),
                sufix: suffix
            )
        }

        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "not found id or group_id "))
    }
}

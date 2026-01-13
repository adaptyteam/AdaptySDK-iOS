//
//  Schema.StringReference.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

extension Schema {
    typealias StringReference = VC.StringReference
}

extension Schema.StringReference: Codable {
    enum CodingKeys: String, CodingKey {
        case value = "var"
        case type
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.value) {
            let value = try container.decode(String.self, forKey: .value)
            self = .value(path: value.split(separator: ".").map(String.init))
            return
        }

        if container.contains(.type) {
            let type = try container.decode(String.self, forKey: .type)
            guard type == Product.typeValue else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [Product.CodingKeys.type], debugDescription: "unknown value"))
            }

            self = try .product(Product(from: decoder))
            return
        }

        let stringId = try decoder.singleValueContainer().decode(String.self)
        self = .stringId(stringId)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .stringId(string):
            try container.encode(string)
        case let .product(product):
            try container.encode(product)
        case let .value(path):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(path.joined(separator: "."), forKey: .value)
        }
    }
}

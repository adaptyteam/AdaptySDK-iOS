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
        case variable = "var"
        case type
    }

    package init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            self = try .stringId(decoder.singleValueContainer().decode(String.self))
            return
        }

        guard !container.contains(.variable) else {
            self = try .variable(Schema.Variable(from: decoder))
            return
        }

        let type = try container.decode(String.self, forKey: .type)
        guard type == Product.typeValue else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [Product.CodingKeys.type], debugDescription: "unknown value"))
        }

        self = try .product(Product(from: decoder))
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .stringId(string):
            try container.encode(string)
        case let .product(product):
            try container.encode(product)
        case let .variable(variable):
            try container.encode(variable)
        }
    }
}

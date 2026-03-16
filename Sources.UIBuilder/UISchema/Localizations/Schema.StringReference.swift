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
        case stringId = "string_id"
        case variable = "var"
        case product
        case legacyProduct = "type"
    }

    init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            self = try .stringId(decoder.singleValueContainer().decode(String.self), nil)
            return
        }

        guard !container.contains(.stringId) else {
            let id = try container.decode(String.self, forKey: .stringId)
            var tags = try decoder.singleValueContainer().decode([String: TagValue].self)
            tags.removeValue(forKey: CodingKeys.stringId.rawValue)
            if tags.isEmpty {
                self = .stringId(id, nil)
            } else {
                tags.reserveCapacity(tags.count)
                self = .stringId(id, tags)
            }
            return
        }

        guard !container.contains(.variable) else {
            self = try .variable(Schema.Variable(from: decoder))
            return
        }

        guard !container.contains(.product), !container.contains(.legacyProduct) else {
            self = try .product(Product(from: decoder))
            return
        }

        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "value must be string_id or variable "))
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .stringId(string, tags):
            guard let tags, tags.isNotEmpty else {
                try container.encode(string)
                return
            }
            try container.encode(tags)
            var objContainer = encoder.container(keyedBy: CodingKeys.self)
            try objContainer.encode(string, forKey: .stringId)
        case let .product(product):
            try container.encode(product)
        case let .variable(variable):
            try container.encode(variable)
        }
    }
}

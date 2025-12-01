//
//  Schema.Box.Length.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema.Box {
    typealias Length = VC.Box.Length
}

extension Schema.Box.Length: Codable {
    enum CodingKeys: String, CodingKey {
        case min
        case max
        case shrink
        case fillMax = "fill_max"
    }

    package init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(Schema.Unit.self) {
            self = .fixed(value)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try container.decodeIfPresent(Bool.self, forKey: .fillMax), value {
                self = .fillMax
            } else if let value = try container.decodeIfPresent(Schema.Unit.self, forKey: .min) {
                self = try .flexible(min: value, max: container.decodeIfPresent(Schema.Unit.self, forKey: .max))
            } else if let value = try container.decodeIfPresent(Schema.Unit.self, forKey: .shrink) {
                self = try .shrinkable(min: value, max: container.decodeIfPresent(Schema.Unit.self, forKey: .max))
            } else if let value = try container.decodeIfPresent(Schema.Unit.self, forKey: .max) {
                self = .flexible(min: nil, max: value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "don't found unknown properties"))
            }
        }
    }

    package func encode(to encoder: any Encoder) throws {
        switch self {
        case let .fixed(unit):
            try unit.encode(to: encoder)
        case let .flexible(min, max):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(min, forKey: .min)
            try container.encodeIfPresent(max, forKey: .max)
        case let .shrinkable(min, max):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(min, forKey: .shrink)
            try container.encodeIfPresent(max, forKey: .max)
        case .fillMax:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(true, forKey: .fillMax)
        }
    }
}

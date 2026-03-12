//
//  Schema.Parameter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.12.2025.
//

import Foundation

extension Schema {
    typealias Parameter = VC.Parameter
}

extension Schema.Parameter: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let v = try? container.decode(Bool.self) {
            self = .bool(v)
        } else if let v = try? container.decode(Int32.self) {
            self = .int32(v)
        } else if let v = try? container.decode(UInt32.self) {
            self = .uint32(v)
        } else if let v = try? container.decode(Double.self) {
            self = .double(v)
        } else if let v = try? container.decode(String.self) {
            self = .string(v)
        } else if let v = try? container.decode([String: Schema.Parameter].self) {
            self = .object(v)
        } else {
            throw DecodingError.typeMismatch(
                Schema.Parameter.self,
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Unsupported value type"
                )
            )
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case let .bool(value):
            try container.encode(value)
        case let .int32(value):
            try container.encode(value)
        case let .uint32(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        case let .object(value):
            try container.encode(value)
        }
    }
}

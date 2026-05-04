//
//  AnyCodable.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation

struct AnyCodable: Sendable, Hashable, Codable {
    let wrapped: any Sendable & Hashable & Codable

    init(_ value: any Sendable & Hashable & Codable) {
        if let value = value as? AnyCodable {
            self = value
        } else {
            wrapped = value
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        AnyHashable(lhs.wrapped) == AnyHashable(rhs.wrapped)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(AnyHashable(wrapped))
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(String?.none)
            return
        }
        if let value = try? container.decode(Bool.self) {
            self.init(value)
            return
        }
        if let value = try? container.decode(Int.self) {
            self.init(value)
            return
        }
        if let value = try? container.decode(UInt.self) {
            self.init(value)
            return
        }
        if let value = try? container.decode(Double.self) {
            self.init(value)
            return
        }
        if let value = try? container.decode(String.self) {
            self.init(value)
            return
        }
        if let value = try? container.decode([AnyCodable].self) {
            self.init(value)
            return
        }
        if let value = try? container.decode([String: AnyCodable].self) {
            self.init(value)
            return
        }
        throw DecodingError.typeMismatch(
            Self.self,
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported AnyCodable type"
            )
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        if isNil(wrapped) {
            try container.encodeNil()
            return
        }

        switch wrapped {
        case let value as Bool:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as UInt:
            try container.encode(value)
        case let value as Double:
            try container.encode(value)
        case let value as String:
            try container.encode(value)
        case let value as [AnyCodable]:
            try container.encode(value)
        case let value as [String: AnyCodable]:
            try container.encode(value)
        case let value as any Encodable:
            try value.encode(to: encoder)
        default:
            throw EncodingError.invalidValue(
                wrapped,
                .init(
                    codingPath: encoder.codingPath,
                    debugDescription: "Unsupported AnyCodable type: \(type(of: wrapped))"
                )
            )
        }
    }
}


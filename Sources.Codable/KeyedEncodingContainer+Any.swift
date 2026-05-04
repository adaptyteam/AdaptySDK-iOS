//
//  KeyedEncodingContainer+Any.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 12.04.2026.
//

import Foundation

public extension KeyedEncodingContainer<AnyCodingKey> {
    @inlinable
    mutating func encodeDictionary(_ dict: [String: Any], skipNonEncodableValues: Bool = false) throws {
        for (key, value) in dict {
            try encodeAnyIfPresent(value, skipNonEncodableValues: skipNonEncodableValues, forKey: AnyCodingKey(stringValue: key))
        }
    }

    @inlinable
    mutating func encodeDicttionaryIfPresent(_ dict: [String: Any]?, skipNonEncodableValues: Bool = false) throws {
        guard let dict else { return }
        return try encodeDictionary(dict, skipNonEncodableValues: skipNonEncodableValues)
    }
}

public extension KeyedEncodingContainer {
    @inlinable
    mutating func encodeArray(_ array: [Any], skipNonEncodableValues: Bool = false, forKey k: Key) throws {
        var container = nestedUnkeyedContainer(forKey: k)
        try container.encodeArray(array, skipNonEncodableValues: skipNonEncodableValues)
    }

    @inlinable
    mutating func encodeArrayIfPresent(_ array: [Any]?, skipNonEncodableValues: Bool = false, forKey k: Key) throws {
        guard let array else { return }
        try encodeArray(array, skipNonEncodableValues: skipNonEncodableValues, forKey: k)
    }

    @inlinable
    mutating func encodeDictionary(_ dict: [String: Any], skipNonEncodableValues: Bool = false, forKey k: Key) throws {
        var container = nestedContainer(keyedBy: AnyCodingKey.self, forKey: k)
        try container.encodeDictionary(dict, skipNonEncodableValues: skipNonEncodableValues)
    }

    @inlinable
    mutating func encodeDictionaryIfPresent(_ dict: [String: Any]?, skipNonEncodableValues: Bool = false, forKey k: Key) throws {
        guard let dict else { return }
        try encodeDictionary(dict, skipNonEncodableValues: skipNonEncodableValues, forKey: k)
    }

    @inlinable
    mutating func encodeAnyIfPresent(_ value: Any, skipNonEncodableValues: Bool = false, forKey k: Key) throws {
        if isNil(value) { return }
        switch value {
        case let value as [String: Any]:
            try encodeDictionary(value, skipNonEncodableValues: skipNonEncodableValues, forKey: k)
        case let value as [Any]:
            try encodeArray(value, skipNonEncodableValues: skipNonEncodableValues, forKey: k)
        case let value as any Encodable:
            try encode(value, forKey: k)
        default:
            if skipNonEncodableValues {
                return
            }
            throw EncodingError.invalidValue(
                value,
                .init(
                    codingPath: codingPath + [k],
                    debugDescription: "Unsupported non encodable value type: \(type(of: value))"
                )
            )
        }
    }
}

public extension UnkeyedEncodingContainer {
    @inlinable
    mutating func encodeArray(_ array: [Any], skipNonEncodableValues: Bool = false) throws {
        for value in array {
            try encodeAnyIfPresent(value, skipNonEncodableValues: skipNonEncodableValues)
        }
    }

    @inlinable
    mutating func encodeArrayIfPresent(_ array: [Any]?, skipNonEncodableValues: Bool = false) throws {
        guard let array else { return }
        try encodeArray(array, skipNonEncodableValues: skipNonEncodableValues)
    }

    @inlinable
    mutating func encodeAnyIfPresent(_ value: Any, skipNonEncodableValues: Bool = false) throws {
        if isNil(value) { return }
        switch value {
        case let value as [String: Any]:
            var container = nestedContainer(keyedBy: AnyCodingKey.self)
            try container.encodeDictionary(value, skipNonEncodableValues: skipNonEncodableValues)
        case let value as [Any]:
            var container = nestedUnkeyedContainer()
            try container.encodeArray(value, skipNonEncodableValues: skipNonEncodableValues)
        case let value as any Encodable:
            try encode(value)
        default:
            if skipNonEncodableValues {
                return
            }
            throw EncodingError.invalidValue(
                value,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Unsupported non encodable value type: \(type(of: value))"
                )
            )
        }
    }
}


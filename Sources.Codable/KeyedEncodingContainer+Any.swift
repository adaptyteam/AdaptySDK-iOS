//
//  KeyedEncodingContainer+Any.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 12.04.2026.
//

import Foundation

public extension KeyedEncodingContainer<AnyCodingKey> {
    @inlinable
    mutating func encodeDictionary(_ dict: [String: Any], omittingNullValues: Bool = false, skipNonEncodableValues: Bool = false) throws {
        for (key, value) in dict {
            try encodeAnyIfPresent(value, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues, forKey: AnyCodingKey(stringValue: key))
        }
    }

    @inlinable
    mutating func encodeDicttionaryIfPresent(_ dict: [String: Any]?, omittingNullValues: Bool = false, skipNonEncodableValues: Bool = false) throws {
        guard let dict else { return }
        return try encodeDictionary(dict, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues)
    }
}

public extension KeyedEncodingContainer {
    @inlinable
    mutating func encodeArray(_ array: [Any], omittingNullValues: Bool = false, skipNonEncodableValues: Bool = false, forKey k: Key) throws {
        var container = nestedUnkeyedContainer(forKey: k)
        try container.encodeArray(array, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues)
    }

    @inlinable
    mutating func encodeArrayIfPresent(_ array: [Any]?, omittingNullValues: Bool = false, skipNonEncodableValues: Bool = false, forKey k: Key) throws {
        guard let array else { return }
        try encodeArray(array, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues, forKey: k)
    }

    @inlinable
    mutating func encodeDictionary(_ dict: [String: Any], omittingNullValues: Bool = false, skipNonEncodableValues: Bool = false, forKey k: Key) throws {
        var container = nestedContainer(keyedBy: AnyCodingKey.self, forKey: k)
        try container.encodeDictionary(dict, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues)
    }

    @inlinable
    mutating func encodeDictionaryIfPresent(_ dict: [String: Any]?, omittingNullValues: Bool = false, skipNonEncodableValues: Bool = false, forKey k: Key) throws {
        guard let dict else { return }
        try encodeDictionary(dict, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues, forKey: k)
    }

    mutating func encodeAnyIfPresent(_ unknownValue: Any, omittingNullValues: Bool = false, skipNonEncodableValues: Bool = false, forKey k: Key) throws {
        if isNil(unknownValue) {
            if !omittingNullValues { try encodeNil(forKey: k) }
            return
        }
        switch unknownValue {
        case let value as [String: Any]:
            try encodeDictionary(value, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues, forKey: k)
        case let value as [Any]:
            try encodeArray(value, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues, forKey: k)
        case let value as any Encodable:
            try encode(value, forKey: k)
        default:
            if let value = convertToEncodable(unknownValue) {
                try encode(value, forKey: k)
                return
            }
            if skipNonEncodableValues {
                return
            }
            throw EncodingError.invalidValue(
                unknownValue,
                .init(
                    codingPath: codingPath + [k],
                    debugDescription: "Unsupported non encodable value type: \(type(of: unknownValue))"
                )
            )
        }
    }
}

public extension UnkeyedEncodingContainer {
    @inlinable
    mutating func encodeArray(_ array: [Any], omittingNullValues: Bool = false, skipNonEncodableValues: Bool = false) throws {
        for value in array {
            try encodeAnyIfPresent(value, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues)
        }
    }

    @inlinable
    mutating func encodeArrayIfPresent(_ array: [Any]?, omittingNullValues: Bool = false, skipNonEncodableValues: Bool = false) throws {
        guard let array else { return }
        try encodeArray(array, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues)
    }

    mutating func encodeAnyIfPresent(_ unknownValue: Any, omittingNullValues: Bool = false, skipNonEncodableValues: Bool = false) throws {
        // array elements are positional: any nil becomes null regardless of omittingNullValues
        if isNil(unknownValue) {
            try encodeNil()
            return
        }
        switch unknownValue {
        case let value as [String: Any]:
            var container = nestedContainer(keyedBy: AnyCodingKey.self)
            try container.encodeDictionary(value, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues)
        case let value as [Any]:
            var container = nestedUnkeyedContainer()
            try container.encodeArray(value, omittingNullValues: omittingNullValues, skipNonEncodableValues: skipNonEncodableValues)
        case let value as any Encodable:
            try encode(value)
        default:
            if let value = convertToEncodable(unknownValue) {
                try encode(value)
                return
            }
            if skipNonEncodableValues {
                try encodeNil() // array elements are positional: write null instead of shifting the following elements
                return
            }
            throw EncodingError.invalidValue(
                unknownValue,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Unsupported non encodable value type: \(type(of: unknownValue))"
                )
            )
        }
    }
}

private func convertToEncodable(_ value: Any) -> (any Encodable)? {
    switch value {
    case let number as NSNumber:
        if CFGetTypeID(number) == CFBooleanGetTypeID() {
            return number.boolValue
        }
        let typeChar = String(cString: number.objCType)

        if ["Q", "I", "L", "S", "C"].contains(typeChar) {
            return number.uint64Value
        }
        if ["q", "i", "l", "s", "c"].contains(typeChar) {
            return number.int64Value
        }
        return number.doubleValue

    case let string as NSString:
        return string as String

    default:
        return nil
    }
}


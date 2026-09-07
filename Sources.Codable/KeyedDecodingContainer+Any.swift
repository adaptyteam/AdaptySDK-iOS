//
//  KeyedDecodingContainer+Any.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 12.04.2026.
//

import Foundation

public extension KeyedDecodingContainer<AnyCodingKey> {
    func decodeDictionary(omittingNullValues: Bool = false) throws -> [String: any Sendable] {
        try [String: any Sendable](
            allKeys.compactMap {
                guard let value = try decodeAnyIfPresent(forKey: $0, omittingNullValues: omittingNullValues)
                else { return nil }
                return ($0.stringValue, value)
            },
            uniquingKeysWith: { $1 }
        )
    }
}

public extension KeyedDecodingContainer {
    func decodeArray(forKey k: Key, omittingNullValues: Bool = false) throws -> [any Sendable] {
        var container = try nestedUnkeyedContainer(forKey: k)
        return try container.decodeArray(omittingNullValues: omittingNullValues)
    }

    func decodeArrayIfPresent(forKey k: Key, omittingNullValues: Bool = false) throws -> [any Sendable]? {
        guard contains(k) else { return nil }
        return try decodeArray(forKey: k, omittingNullValues: omittingNullValues)
    }

    func decodeDictionary(forKey k: Key, omittingNullValues: Bool = false) throws -> [String: any Sendable] {
        let container = try nestedContainer(keyedBy: AnyCodingKey.self, forKey: k)
        return try container.decodeDictionary(omittingNullValues: omittingNullValues)
    }

    func decodeDictionaryIfPresent(forKey k: Key, omittingNullValues: Bool = false) throws -> [String: any Sendable]? {
        guard contains(k) else { return nil }
        return try decodeDictionary(forKey: k, omittingNullValues: omittingNullValues)
    }

    func decodeAnyIfPresent(forKey k: Key, omittingNullValues: Bool = false) throws -> (any Sendable)? {
        guard contains(k) else { return nil }

        if try decodeNil(forKey: k) {
            return omittingNullValues ? nil : NSNull()
        }
        if let container = try? nestedContainer(keyedBy: AnyCodingKey.self, forKey: k) {
            return try container.decodeDictionary(omittingNullValues: omittingNullValues)
        }
        if var container = try? nestedUnkeyedContainer(forKey: k) {
            return try container.decodeArray(omittingNullValues: omittingNullValues)
        }
        if let value = try? decode(Bool.self, forKey: k) {
            return value
        }
        if let value = try? decode(Int.self, forKey: k) {
            return value
        }
        if let value = try? decode(UInt.self, forKey: k) {
            return value
        }
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
            if let value = try? decode(Int128.self, forKey: k) {
                return value
            }
            if let value = try? decode(UInt128.self, forKey: k) {
                return value
            }
        }
        if let value = try? decode(Double.self, forKey: k) {
            return value
        }
        if let value = try? decode(String.self, forKey: k) {
            return value
        }

        throw DecodingError.typeMismatch(
            Any.self,
            .init(
                codingPath: codingPath + [k],
                debugDescription: "Unsupported decoded value type"
            )
        )
    }
}

public extension UnkeyedDecodingContainer {
    mutating func decodeArray(omittingNullValues: Bool = false) throws -> [any Sendable] {
        var result = [any Sendable]()
        while !isAtEnd {
            if let value = try decodeAnyIfPresent(omittingNullValues: omittingNullValues) {
                result.append(value)
            }
        }
        return result
    }

    mutating func decodeAnyIfPresent(omittingNullValues: Bool = false) throws -> (any Sendable)? {
        if try decodeNil() {
            return omittingNullValues ? nil : NSNull()
        }
        if let container = try? nestedContainer(keyedBy: AnyCodingKey.self) {
            return try container.decodeDictionary(omittingNullValues: omittingNullValues)
        }
        if var container = try? nestedUnkeyedContainer() {
            return try container.decodeArray(omittingNullValues: omittingNullValues)
        }
        if let value = try? decode(Bool.self) {
            return value
        }
        if let value = try? decode(Int.self) {
            return value
        }
        if let value = try? decode(UInt.self) {
            return value
        }
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
            if let value = try? decode(Int128.self) {
                return value
            }
            if let value = try? decode(UInt128.self) {
                return value
            }
        }
        if let value = try? decode(Double.self) {
            return value
        }
        if let value = try? decode(String.self) {
            return value
        }

        throw DecodingError.typeMismatch(
            Any.self,
            .init(
                codingPath: codingPath,
                debugDescription: "Unsupported decoded value type"
            )
        )
    }
}


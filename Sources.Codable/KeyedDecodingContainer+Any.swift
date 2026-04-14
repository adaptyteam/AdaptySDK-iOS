//
//  KeyedDecodingContainer+Any.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 12.04.2026.
//

import Foundation

public extension KeyedDecodingContainer<AnyCodingKey> {
    func decodeDictionary() throws -> [String: Any] {
        try [String: Any](
            allKeys.compactMap {
                guard let value = try decodeAnyIfPresent(forKey: $0)
                else { return nil }
                return ($0.stringValue, value)
            },
            uniquingKeysWith: { $1 }
        )
    }
}

public extension KeyedDecodingContainer {
    func decodeArray(forKey k: Key) throws -> [Any] {
        var container = try nestedUnkeyedContainer(forKey: k)
        return try container.decodeArray()
    }

    func decodeArrayIfPresent(forKey k: Key) throws -> [Any]? {
        guard contains(k) else { return nil }
        return try decodeArray(forKey: k)
    }

    func decodeDictionary(forKey k: Key) throws -> [String: Any] {
        let container = try nestedContainer(keyedBy: AnyCodingKey.self, forKey: k)
        return try container.decodeDictionary()
    }

    func decodeDictionaryIfPresent(forKey k: Key) throws -> [String: Any]? {
        guard contains(k) else { return nil }
        return try decodeDictionary(forKey: k)
    }

    func decodeAnyIfPresent(forKey k: Key) throws -> Any? {
        guard contains(k) else { return nil }

        if try decodeNil(forKey: k) {
            return nil
        }
        if let container = try? nestedContainer(keyedBy: AnyCodingKey.self, forKey: k) {
            return try container.decodeDictionary()
        }
        if var container = try? nestedUnkeyedContainer(forKey: k) {
            return try container.decodeArray()
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
    mutating func decodeArray() throws -> [Any] {
        var result = [Any]()
        while !isAtEnd {
            if let value = try decodeAnyIfPresent() {
                result.append(value)
            }
        }
        return result
    }

    mutating func decodeAnyIfPresent() throws -> Any? {
        if try decodeNil() {
            return nil
        }
        if let container = try? nestedContainer(keyedBy: AnyCodingKey.self) {
            return try container.decodeDictionary()
        }
        if var container = try? nestedUnkeyedContainer() {
            return try container.decodeArray()
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


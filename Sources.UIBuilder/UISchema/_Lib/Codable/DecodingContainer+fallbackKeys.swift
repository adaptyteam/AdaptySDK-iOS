//
//  DecodingContainer+fallbackKeys.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 05.12.2025.
//

import Foundation

extension KeyedDecodingContainer {
    private func findKey(_ key: Key, _ fallback: [Key]) -> Key {
        if contains(key) {
            key
        } else {
            fallback.first(where: contains) ?? key
        }
    }

    func decode<T>(_ type: T.Type, forKeys key: Key, _ fallback: Key...) throws -> T where T: Decodable {
        try decode(type, forKey: findKey(key, fallback))
    }

    func decodeIfPresent<T>(_ type: T.Type, forKeys key: Key, _ fallback: Key...) throws -> T? where T: Decodable {
        try decodeIfPresent(type, forKey: findKey(key, fallback))
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKeys key: Key, _ fallback: Key...) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try nestedContainer(keyedBy: type, forKey: findKey(key, fallback))
    }

    func nestedUnkeyedContainer(forKeys key: Key, _ fallback: Key...) throws -> any UnkeyedDecodingContainer {
        try nestedUnkeyedContainer(forKey: findKey(key, fallback))
    }

    func decode<T, C>(_ type: T.Type, forKeys key: Key, _ fallback: Key..., configuration: C.Type) throws -> T where T: DecodableWithConfiguration, C: DecodingConfigurationProviding, T.DecodingConfiguration == C.DecodingConfiguration {
        try decode(type, forKey: findKey(key, fallback), configuration: configuration)
    }

    func decodeIfPresent<T, C>(_ type: T.Type, forKeys key: Key, _ fallback: Key..., configuration: C.Type) throws -> T? where T: DecodableWithConfiguration, C: DecodingConfigurationProviding, T.DecodingConfiguration == C.DecodingConfiguration {
        try decodeIfPresent(type, forKey: findKey(key, fallback), configuration: configuration)
    }

    func decode<T>(_ type: T.Type, forKeys key: Key, _ fallback: Key..., configuration: T.DecodingConfiguration) throws -> T where T: DecodableWithConfiguration {
        try decode(type, forKey: findKey(key, fallback), configuration: configuration)
    }

    func decodeIfPresent<T>(_ type: T.Type, forKeys key: Key, _ fallback: Key..., configuration: T.DecodingConfiguration) throws -> T? where T: DecodableWithConfiguration {
        try decodeIfPresent(type, forKey: findKey(key, fallback), configuration: configuration)
    }
}

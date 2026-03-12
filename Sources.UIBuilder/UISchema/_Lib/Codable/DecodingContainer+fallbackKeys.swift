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

    func decode<T: Decodable>(_ type: T.Type, forKeys key: Key, _ fallback: Key...) throws -> T {
        try decode(type, forKey: findKey(key, fallback))
    }

    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKeys key: Key, _ fallback: Key...) throws -> T? {
        try decodeIfPresent(type, forKey: findKey(key, fallback))
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKeys key: Key, _ fallback: Key...) throws -> KeyedDecodingContainer<NestedKey> {
        try nestedContainer(keyedBy: type, forKey: findKey(key, fallback))
    }

    func nestedUnkeyedContainer(forKeys key: Key, _ fallback: Key...) throws -> any UnkeyedDecodingContainer {
        try nestedUnkeyedContainer(forKey: findKey(key, fallback))
    }

    func decode<T: DecodableWithConfiguration, C: DecodingConfigurationProviding>(_ type: T.Type, forKeys key: Key, _ fallback: Key..., configuration: C.Type) throws -> T where T.DecodingConfiguration == C.DecodingConfiguration {
        try decode(type, forKey: findKey(key, fallback), configuration: configuration)
    }

    func decodeIfPresent<T: DecodableWithConfiguration, C: DecodingConfigurationProviding>(_ type: T.Type, forKeys key: Key, _ fallback: Key..., configuration: C.Type) throws -> T? where T.DecodingConfiguration == C.DecodingConfiguration {
        try decodeIfPresent(type, forKey: findKey(key, fallback), configuration: configuration)
    }

    func decode<T: DecodableWithConfiguration>(_ type: T.Type, forKeys key: Key, _ fallback: Key..., configuration: T.DecodingConfiguration) throws -> T {
        try decode(type, forKey: findKey(key, fallback), configuration: configuration)
    }

    func decodeIfPresent<T: DecodableWithConfiguration>(_ type: T.Type, forKeys key: Key, _ fallback: Key..., configuration: T.DecodingConfiguration) throws -> T? {
        try decodeIfPresent(type, forKey: findKey(key, fallback), configuration: configuration)
    }
}

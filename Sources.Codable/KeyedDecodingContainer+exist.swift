//
//  KeyedDecodingContainer+exist.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 07.04.2026.
//

import Foundation

public extension KeyedDecodingContainer {
    @inlinable
    func exist(_ key: KeyedDecodingContainer<K>.Key) -> Bool {
        guard contains(key) else { return false }

        do {
            return if try decodeNil(forKey: key) {
                false
            } else {
                true
            }
        } catch {
            return false
        }
    }

    /// Workaround: Foundation's `decodeIfPresent(_:forKey:configuration:)` does not handle null values,
    /// unlike the standard `decodeIfPresent(_:forKey:)` for `Decodable`.
    /// This method checks for null before decoding, returning nil instead of throwing.
    @inlinable
    func decodeIfExist<T: DecodableWithConfiguration>(
        _ type: T.Type,
        forKey key: Key,
        configuration: T.DecodingConfiguration
    ) throws -> T? {
        guard exist(key) else { return nil }
        return try decode(type, forKey: key, configuration: configuration)
    }

    /// Workaround: Foundation's `decodeIfPresent(_:forKey:configuration:)` does not handle null values,
    /// unlike the standard `decodeIfPresent(_:forKey:)` for `Decodable`.
    /// This method checks for null before decoding, returning nil instead of throwing.
    @inlinable
    func decodeIfExist<T: DecodableWithConfiguration, C: DecodingConfigurationProviding>(
        _ type: T.Type,
        forKey key: Key,
        configuration: C.Type
    ) throws -> T? where T.DecodingConfiguration == C.DecodingConfiguration {
        guard exist(key) else { return nil }
        return try decode(type, forKey: key, configuration: configuration)
    }
}


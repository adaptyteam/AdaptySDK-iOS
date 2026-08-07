//
//  KeyedDecodingContainer+Array.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 07.04.2026.
//

import Foundation

public extension KeyedDecodingContainer {
    @inlinable
    func isArray(_ key: Key) -> Bool {
        guard exist(key) else { return false }

        do {
            _ = try nestedUnkeyedContainer(forKey: key)
            return true
        } catch {
            return false
        }
    }
}

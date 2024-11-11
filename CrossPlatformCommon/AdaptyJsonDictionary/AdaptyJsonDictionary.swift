//
//  AdaptyJsonDictionary.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty
import Foundation

private let log = Log.plugin

public typealias AdaptyJsonDictionary = [String: any Sendable]

extension AdaptyJsonDictionary {
    func isExist(key: Key) -> Bool { keys.contains(key) }

    func value(forKey key: Key) throws -> KeyValue {
        guard isExist(key: key) else { throw RequestError.notExist(key: key) }
        guard let value = self[key] else { throw RequestError.isNil(key: key) }
        return .init(key: key, value: value)
    }

    func valueIfPresent(forKey key: Key) -> KeyValue? {
        guard let value = self[key] else { return nil }
        return .init(key: key, value: value)
    }

    func value<T: Sendable>(_ valueType: T.Type, forKey key: String) throws -> T {
        try value(forKey: key).cast(valueType)
    }

    func valueIfPresent<T: Sendable>(_ valueType: T.Type, forKey key: String) throws -> T? {
        try valueIfPresent(forKey: key)?.cast(valueType)
    }

    func isExist(key: CodingKey) -> Bool { isExist(key: key.stringValue) }

    func value(forKey key: CodingKey) throws -> KeyValue {
        try value(forKey: key.stringValue)
    }

    func valueIfPresent(forKey key: CodingKey) -> KeyValue? {
        valueIfPresent(forKey: key.stringValue)
    }

    func value<T: Sendable>(_ valueType: T.Type, forKey key: CodingKey) throws -> T {
        try value(forKey: key.stringValue).cast(valueType)
    }

    func valueIfPresent<T: Sendable>(_ valueType: T.Type, forKey key: CodingKey) throws -> T? {
        try valueIfPresent(forKey: key.stringValue)?.cast(valueType)
    }
}

struct KeyValue {
    let key: String
    let value: any Sendable

    init(key: String, value: any Sendable) {
        self.key = key
        self.value = value
    }

    init(key: CodingKey, value: any Sendable) {
        self.key = key.stringValue
        self.value = value
    }
}

extension KeyValue {
    @usableFromInline
    func cast<T: Sendable>(_ valueType: T.Type) throws -> T {
        guard let result: T = value as? T else {
            throw RequestError.wrongType(key: key, expected: valueType, present: type(of: value))
        }
        return result
    }

    func decode<T: Decodable>(_ valueType: T.Type) throws -> T {
        if let value: T = value as? T { return value }
        guard let jsonData: Data = (value as? Data) ?? (value as? String)?.data(using: .utf8) else {
            throw RequestError.wrongType(key: key, expected: Data.self, present: type(of: value))
        }
        return try jsonData.decode(valueType)
    }
}

//
//  AdaptyJsonDictionary.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty

private let log = Log.plugin

public typealias AdaptyJsonDictionary = [String: any Sendable]

extension AdaptyJsonDictionary {
    func isExist(key: CodingKey) -> Bool { isExist(key: key.stringValue) }
    func decode<T: Sendable>(_ valueType: T.Type, forKey key: CodingKey) throws -> T {
        try decode(valueType, forKey: key.stringValue)
    }

    func decodeIfPresent<T: Sendable>(_ valueType: T.Type, forKey key: CodingKey) throws -> T? {
        try decodeIfPresent(valueType, forKey: key.stringValue)
    }

    func isExist(key: String) -> Bool { keys.contains(key) }

    func decode<T: Sendable>(_ valueType: T.Type, forKey key: String) throws -> T {
        guard isExist(key: key) else { throw RequestError.notExist(key: key) }
        guard let value = self[key] else { throw RequestError.isNil(key: key) }
        guard let result: T = value as? T else {
            throw RequestError.wrongType(key: key, expected: valueType, present: type(of: value))
        }

        return result
    }

    func decodeIfPresent<T: Sendable>(_ valueType: T.Type, forKey key: String) throws -> T? {
        guard isExist(key: key) else { return nil }
        guard let value = self[key] else { return nil }
        guard let result: T = value as? T else {
            throw RequestError.wrongType(key: key, expected: valueType, present: type(of: value))
        }

        return result
    }
}

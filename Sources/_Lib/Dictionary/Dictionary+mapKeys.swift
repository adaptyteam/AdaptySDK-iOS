//
//  Dictionary+mapKeys.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.11.2025.
//

import Foundation

extension Dictionary {
    func mapKeys<T>(_ transform: (Key) throws -> T) rethrows -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            let newKey = try transform(key)
            result[newKey] = value
        }
        return result
    }

    func mapKeys<T>(_ transform: (Key) throws -> T?) rethrows -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            if let newKey = try transform(key) {
                result[newKey] = value
            }
        }
        return result
    }
}

//
//  VH.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct VH<Value> {
    let value: Value
    let hash: String?
    let time: Date?

    private init(_ value: Value, hash: String?, time: Date?) {
        self.value = value
        self.hash = hash
        self.time = time
    }

    init(_ value: Value, hash: String?) {
        self.init(value, hash: hash, time: nil)
    }

    init(_ value: Value, time: Date) {
        self.init(value, hash: nil, time: time)
    }

    enum CodingKeys: String, CodingKey {
        case value = "v"
        case hash = "h"
        case time = "t"
    }

    @inlinable func mapValue<U>(_ transform: (Value) -> U) -> VH<U> {
        VH<U>(transform(value), hash: hash, time: time)
    }
}

extension VH: Encodable where Value: Encodable {}

extension VH: Decodable where Value: Decodable {}

extension VH {
    @inlinable func flatValue<T>() -> VH<T>? where Value == T? {
        switch value {
        case .none:
            return .none
        case let .some(v):
            return VH<T>(v, hash: hash, time: time)
        }
    }
}

//
//  VC.AnyValue.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation
import AdaptyCodable

extension VC {
    protocol Value: Sendable, Hashable, JSValueConvertable {}

    struct AnyValue: Value {
        let wrapped: any Value

        init(_ value: any Value) {
            if let value = value as? Self {
                self = value
            } else {
                wrapped = value
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            AnyHashable(lhs.wrapped) == AnyHashable(rhs.wrapped)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(AnyHashable(wrapped))
        }
    }
}

extension Bool: VC.Value {}
extension Int: VC.Value {}
extension UInt: VC.Value {}
extension Int32: VC.Value {}
extension UInt32: VC.Value {}
extension Double: VC.Value {}
extension String: VC.Value {}
extension Optional: VC.Value where Wrapped: VC.Value {}

extension Array: VC.Value where Element: VC.Value {}
extension Dictionary: VC.Value where Key == String, Value: VC.Value {}



extension VC.Value {
    var isNil: Bool {
        if let value = self as? VC.AnyValue {
            return value.wrapped.isNil
        }
        return AdaptyCodable.isNil(self)
    }

    var isArray: Bool {
        if let value = self as? VC.AnyValue {
            return value.wrapped.isArray
        }
        return self is [any VC.Value]
    }

    var isObject: Bool {
        if let value = self as? VC.AnyValue {
            return value.wrapped.isObject
        }
        return self is [String: any VC.Value]
    }

    var asArray: [any VC.Value]? {
        if let value = self as? VC.AnyValue {
            return value.wrapped.asArray
        }
        guard let value = self as? [any VC.Value] else { return nil }
        return value
    }

    var asObject: [String: any VC.Value]? {
        if let value = self as? VC.AnyValue {
            return value.wrapped.asObject
        }
        guard let value = self as? [String: any VC.Value] else { return nil }
        return value
    }
}


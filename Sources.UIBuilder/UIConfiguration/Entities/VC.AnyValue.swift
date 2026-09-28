//
//  VC.AnyValue.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import AdaptyCodable
import Foundation

protocol VCValue: Sendable, JSValueConvertable {}

extension VC {
    struct AnyValue: VCValue {
        let wrapped: any VCValue

        init(_ value: any VCValue) {
            if let value = value as? Self {
                self = value
            } else {
                wrapped = value
            }
        }
    }
}

extension Bool: VCValue {}
extension Int: VCValue {}
extension UInt: VCValue {}
extension Int32: VCValue {}
extension UInt32: VCValue {}
extension Double: VCValue {}
extension String: VCValue {}
extension Optional: VCValue where Wrapped: VCValue {}

extension Array: VCValue where Element: VCValue {}
extension Dictionary: VCValue where Key == String, Value: VCValue {}

extension VCValue {
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
        return self is [any VCValue]
    }

    var isObject: Bool {
        if let value = self as? VC.AnyValue {
            return value.wrapped.isObject
        }
        return self is [String: any VCValue]
    }

    var asArray: [any VCValue]? {
        if let value = self as? VC.AnyValue {
            return value.wrapped.asArray
        }
        guard let value = self as? [any VCValue] else { return nil }
        return value
    }

    var asObject: [String: any VCValue]? {
        if let value = self as? VC.AnyValue {
            return value.wrapped.asObject
        }
        guard let value = self as? [String: any VCValue] else { return nil }
        return value
    }
}

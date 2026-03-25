//
//  JSValueRepresentable.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.12.2025.
//

import Foundation
import JavaScriptCore

protocol JSValueRepresentable: Sendable, Hashable {
    static func fromJSValue(_: JSValue) -> Self?
}

extension JSValueRepresentable {
    static func fromJSValue(_ value: JSValue?) -> Self? {
        if case let .some(value) = value {
            fromJSValue(value)
        } else {
            nil
        }
    }
}

// extension Optional: JSValueRepresentable where Wrapped: JSValueRepresentable {
//    static func fromJSValue(_ value: JSValue) -> Self? {
//        Wrapped.fromJSValue(value)
//    }
// }

extension Bool: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> Bool? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else { value.toBool() }
    }
}

extension Int32: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> Int32? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else { value.toInt32() }
    }
}

extension UInt32: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> UInt32? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else { value.toUInt32() }
    }
}

extension Double: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> Double? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else { value.toDouble() }
    }
}

extension String: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> String? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else { value.toString() }
    }
}

//extension VC.Parameter: JSValueRepresentable {
//    static func fromJSValue(_ value: JSValue) -> VC.Parameter? {
//        if value.isUndefined { nil }
//        else if value.isNull { .null }
//        else if value.isBoolean { .bool(value.toBool()) }
//        else if value.isNumber {
//            let d = value.toDouble()
//            if d == d.rounded(.towardZero) {
//                if let i = Int32(exactly: d) {
//                    .int32(i)
//                } else if let u = UInt32(exactly: d) {
//                    .uint32(u)
//                } else {
//                    .double(d)
//                }
//            } else {
//                .double(d)
//            }
//        } else if value.isString { value.toString().map { .string($0) } }
//        else if value.isObject, let dict = value.toDictionary() as? [String: Any] {
//            var result = [String: VC.Parameter]()
//            for (key, _) in dict {
//                if let jsVal = value.objectForKeyedSubscript(key),
//                   let param = fromJSValue(jsVal) {
//                    result[key] = param
//                }
//            }
//            .object(result)
//        } else {
//            nil
//        }
//    }
//}

extension VC.AssetIdentifierOrValue: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> VC.AssetIdentifierOrValue? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else if let value = value.toString() {
            if let color = VC.Color(rawValue: value) {
                .color(color)
            } else {
                .assetId(value)
            }
        } else {
            nil
        }
    }
}

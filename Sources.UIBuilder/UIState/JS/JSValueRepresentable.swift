//
//  JSValueRepresentable.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.12.2025.
//

import Foundation
import JavaScriptCore

protocol JSValueRepresentable: Sendable {
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

extension Array: JSValueRepresentable where Element: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> Self? {
        guard value.isArray,
              let length = value.forProperty("length"), length.isNumber,
              let count = UInt32(exactly: length.toDouble()) else { return nil }

        var result: Self = []
        for index in 0..<Int(count) {
            guard let value = value.atIndex(index),
                  let element = Element.fromJSValue(value) else { return nil }
            result.append(element)
        }
        return result
    }
}

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

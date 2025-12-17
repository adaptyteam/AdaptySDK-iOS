//
//  JSValueRepresentable.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.12.2025.
//

import Foundation
import JavaScriptCore

protocol JSValueRepresentable: Sendable, Hashable, JSValueConvertable {
    static func fromJSValue(_: JSValue) -> Self?
}

extension JSValueRepresentable {
    static func fromJSValue(_ value: JSValue?) -> Self? {
        if case .some(let value) = value {
            fromJSValue(value)
        } else {
            nil
        }
    }
}

extension Optional: JSValueRepresentable where Wrapped: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> Self? {
        Wrapped.fromJSValue(value)
    }
}

extension Bool: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> Bool? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else { value.toBool() }
    }

    func toJSValue(in context: JSContext) -> JSValue {
        .init(bool: self, in: context)
    }
}

extension Int32: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> Int32? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else { value.toInt32() }
    }

    func toJSValue(in context: JSContext) -> JSValue {
        .init(int32: self, in: context)
    }
}

extension UInt32: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> UInt32? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else { value.toUInt32() }
    }

    func toJSValue(in context: JSContext) -> JSValue {
        .init(uInt32: self, in: context)
    }
}

extension Double: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> Double? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else { value.toDouble() }
    }

    func toJSValue(in context: JSContext) -> JSValue {
        .init(double: self, in: context)
    }
}

extension String: JSValueRepresentable {
    static func fromJSValue(_ value: JSValue) -> String? {
        if value.isUndefined { nil }
        else if value.isNull { nil }
        else { value.toString() }
    }

    func toJSValue(in context: JSContext) -> JSValue {
        .init(object: self, in: context)
    }
}

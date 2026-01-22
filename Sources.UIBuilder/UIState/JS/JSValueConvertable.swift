//
//  VC.Action+JSValueConvertable.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.12.2025.
//

import Foundation
import JavaScriptCore

protocol JSValueConvertable {
    func toJSValue(in: JSContext) -> JSValue
}

extension Optional: JSValueConvertable where Wrapped: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        if case let .some(value) = self {
            value.toJSValue(in: context)
        } else {
            .init(nullIn: context)
        }
    }
}

extension Bool: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        .init(bool: self, in: context)
    }
}

extension Int32: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        .init(int32: self, in: context)
    }
}

extension UInt32: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        .init(uInt32: self, in: context)
    }
}

extension Double: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        .init(double: self, in: context)
    }
}

extension String: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        .init(object: self, in: context)
    }
}

extension VC.Action.Parameter: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        switch self {
        case .null:
            .init(nullIn: context)
        case let .string(v): v.toJSValue(in: context)
        case let .bool(v): v.toJSValue(in: context)
        case let .int32(v): v.toJSValue(in: context)
        case let .uint32(v): v.toJSValue(in: context)
        case let .double(v): v.toJSValue(in: context)
        }
    }
}

extension [String: VC.Action.Parameter]: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        for (key, value) in self {
            object.setObject(value.toJSValue(in: context), forKeyedSubscript: key as NSString)
        }
        return object
    }
}

extension VC.AssetIdentifierOrValue: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let value =
            switch self {
            case let .assetId(value): value
            case let .color(color): color.rawValue
            }

        return .init(object: value, in: context)
    }
}

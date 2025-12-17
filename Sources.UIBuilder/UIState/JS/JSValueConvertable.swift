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

extension JSValue: JSValueConvertable {
    func toJSValue(in _: JSContext) -> JSValue {
        self
    }
}

extension [String: VC.Action.Parameter]: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!

        for (key, parameter) in self {
            let value: JSValue = switch parameter {
            case .null:
                .init(nullIn: context)
            case let .string(v):
                .init(object: v, in: context)
            case let .bool(v):
                .init(bool: v, in: context)
            case let .int32(v):
                .init(int32: v, in: context)
            case let .uint32(v):
                .init(uInt32: v, in: context)
            case let .double(v):
                .init(double: v, in: context)
            }
            object.setObject(value, forKeyedSubscript: key as NSString)
        }
        return object
    }
}

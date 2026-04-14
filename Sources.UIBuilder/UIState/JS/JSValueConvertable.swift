//
//  JSValueConvertable.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.12.2025.
//

import AdaptyCodable
import Foundation
import JavaScriptCore

protocol JSValueConvertable {
    func toJSValue(in: JSContext) -> JSValue
}

extension Bool: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        .init(bool: self, in: context)
    }
}

extension Int8: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        .init(int32: Int32(self), in: context)
    }
}

extension UInt8: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        .init(uInt32: UInt32(self), in: context)
    }
}

extension Int16: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        .init(int32: Int32(self), in: context)
    }
}

extension UInt16: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        .init(uInt32: UInt32(self), in: context)
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

extension Int: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        if self <= Int32.max, self >= Int32.min {
            .init(int32: Int32(self), in: context)
        } else {
            .init(double: Double(self), in: context)
        }
    }
}

extension UInt: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        if self <= UInt32.max, self >= UInt32.min {
            .init(uInt32: UInt32(self), in: context)
        } else {
            .init(double: Double(self), in: context)
        }
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

extension VC.AnyValue: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        wrapped.toJSValue(in: context)
    }
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

extension Array: JSValueConvertable where Element: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let array = JSValue(newArrayIn: context)!
        for (index, value) in enumerated() {
            let jsValue = value.toJSValue(in: context)
            array.setObject(jsValue, atIndexedSubscript: index)
        }
        return array
    }
}

extension Dictionary: JSValueConvertable where Key == String, Value: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        for (key, value) in self {
            let jsValue = value.toJSValue(in: context)
            object.setObject(jsValue, forKeyedSubscript: key as NSString)
        }
        return object
    }
}


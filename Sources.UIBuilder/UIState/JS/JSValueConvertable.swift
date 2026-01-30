//
//  VC.Action+JSValueConvertable.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.12.2025.
//

import Foundation
import JavaScriptCore

protocol JSValueConvertable: Sendable, Hashable {
    func toJSValue(in: JSContext) -> JSValue
}

extension Optional: JSValueConvertable where Wrapped: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        if case .some(let value) = self {
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
        case .string(let v): v.toJSValue(in: context)
        case .bool(let v): v.toJSValue(in: context)
        case .int32(let v): v.toJSValue(in: context)
        case .uint32(let v): v.toJSValue(in: context)
        case .double(let v): v.toJSValue(in: context)
        case .object(let v): v.toJSValue(in: context)
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

// extension VC.AssetIdentifierOrValue: JSValueConvertable {
//    func toJSValue(in context: JSContext) -> JSValue {
//        let value =
//            switch self {
//            case .assetId(let value): value
//            case .color(let color): color.rawValue
//            }
//
//        return .init(object: value, in: context)
//    }
// }

extension VS.ScreenInstance: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setObject(id, forKeyedSubscript: "instanceId" as NSString)
        object.setObject(navigatorId, forKeyedSubscript: "navigatorId" as NSString)
        object.setObject(configuration.id, forKeyedSubscript: "type" as NSString)
        object.setObject(contextPath.joined(separator: "."), forKeyedSubscript: "contextPath" as NSString)
        return object
    }
}

extension VS.SetterParameters: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setObject(name, forKeyedSubscript: "name" as NSString)
        object.setObject(value.toJSValue(in: context), forKeyedSubscript: "value" as NSString)
        object.setObject(screenInstance.toJSValue(in: context), forKeyedSubscript: "_screen" as NSString)
        return object
    }
}

//
//  VS.AppMessage.swift
//  AdaptyUIBuilder
//
//  Created by Adapty on 03.09.2026.
//

import CoreFoundation
import Foundation
import JavaScriptCore

extension VS {
    struct AppMessage: Identifiable {

        enum Kind: String {
            case app = "app_msg"
            case customElement = "custom_element_msg"
        }

        let id: String
        let type: Kind
        let screenInstance: ScreenInstance?
        let elementInstance: CustomElementInstance?
        let payload: [String: Any]

        init(id: String, screenInstance: ScreenInstance, customElement: VC.CustomElement, payload: [String: Any]) throws {
            try self.init(
                id: id,
                type: .customElement,
                screenInstance: screenInstance,
                elementInstance: customElement.instance,
                payload: payload
            )
        }

        init(id: String, screenInstance: ScreenInstance, elementInstance: CustomElementInstance, payload: [String: Any]) throws {
            try self.init(
                id: id,
                type: .customElement,
                screenInstance: screenInstance,
                elementInstance: elementInstance,
                payload: payload
            )
        }

        init(id: String, payload: [String: Any]) throws {
            try self.init(
                id: id,
                type: .app,
                screenInstance: nil,
                elementInstance: nil,
                payload: payload
            )
        }

        private init(
            id: String,
            type: Kind,
            screenInstance: ScreenInstance?,
            elementInstance: CustomElementInstance?,
            payload: [String: Any]
        ) throws {
            self.id = id
            self.type = type
            self.screenInstance = screenInstance
            self.elementInstance = elementInstance
            self.payload = payload
        }

        var debugString: String {
            var fields = [String]()
            if let screen = screenInstance {
                fields.append("screen: \(screen.debugString)")
            }
            if let element = elementInstance {
                fields.append("element: \(element.debugString)")
            }
            let message = payload.sorted { $0.key < $1.key }
                .map { "\(String(reflecting: $0.key)): \(String(reflecting: $0.value))" }
                .joined(separator: ", ")
            fields.append("message: {\(message)}")
            return fields.joined(separator: ", ")
        }
    }
}

extension VS.AppMessage: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setValue(id, forProperty: "id")
        object.setValue(type.rawValue, forProperty: "name")
        if let screenInstance {
            object.setValue(screenInstance.toJSValue(in: context), forProperty: "screen")
        }
        if let elementInstance {
            object.setValue(elementInstance.toJSValue(in: context), forProperty: "element")
        }
        var converter = PayloadConverter(context: context)
        object.setValue(converter.convert(payload), forProperty: "payload")
        return object
    }
}

private extension VS.AppMessage {
    /// Builds collections without passing arbitrary native objects to JavaScriptCore.
    /// Unsupported values, dictionaries with non-string keys, cycles and values beyond
    /// the depth limit become null. Array positions and string-keyed properties are preserved.
    /// Custom JSValueConvertable implementations are responsible for their own conversion.
    struct PayloadConverter {
        let context: JSContext
        private var ancestors: Set<ObjectIdentifier> = []

        init(context: JSContext) {
            self.context = context
        }

        mutating func convert(_ value: Any, depth: Int = 0) -> JSValue {
            guard depth <= 128 else { return NSNull().toJSValue(in: context) }

            let mirror = Mirror(reflecting: value)
            if mirror.displayStyle == .optional {
                guard let wrapped = mirror.children.first?.value else {
                    return NSNull().toJSValue(in: context)
                }
                return convert(wrapped, depth: depth + 1)
            }

            // CF access avoids recursively bridging cyclic Foundation collections into Swift.
            if let array = value as? NSArray {
                let identity = ObjectIdentifier(array)
                guard ancestors.insert(identity).inserted else { return NSNull().toJSValue(in: context) }
                defer { ancestors.remove(identity) }

                let container = unsafeBitCast(array, to: CFArray.self)
                let result = JSValue(newArrayIn: context)!
                for index in 0..<CFArrayGetCount(container) {
                    let element = Unmanaged<AnyObject>
                        .fromOpaque(CFArrayGetValueAtIndex(container, index))
                        .takeUnretainedValue()
                    let converted = convert(element, depth: depth + 1)
                    result.setObject(converted, atIndexedSubscript: index)
                }
                return result
            }

            if let dictionary = value as? NSDictionary {
                let identity = ObjectIdentifier(dictionary)
                guard ancestors.insert(identity).inserted else { return NSNull().toJSValue(in: context) }
                defer { ancestors.remove(identity) }

                let container = unsafeBitCast(dictionary, to: CFDictionary.self)
                let count = CFDictionaryGetCount(container)
                var keys = [UnsafeRawPointer?](repeating: nil, count: count)
                var values = [UnsafeRawPointer?](repeating: nil, count: count)
                CFDictionaryGetKeysAndValues(container, &keys, &values)
                var entries: [(String, AnyObject)] = []
                for index in 0..<count {
                    let key = Unmanaged<AnyObject>.fromOpaque(keys[index]!).takeUnretainedValue()
                    guard let name = key as? String else { return NSNull().toJSValue(in: context) }
                    let element = Unmanaged<AnyObject>.fromOpaque(values[index]!).takeUnretainedValue()
                    entries.append((name, element))
                }
                let result = JSValue(newObjectIn: context)!
                for (name, element) in entries {
                    let converted = convert(element, depth: depth + 1)
                    result.defineProperty(name, descriptor: [
                        JSPropertyDescriptorValueKey: converted,
                        JSPropertyDescriptorWritableKey: true,
                        JSPropertyDescriptorEnumerableKey: true,
                        JSPropertyDescriptorConfigurableKey: true,
                    ])
                }
                return result
            }

            if let convertible = value as? any JSValueConvertable {
                return convertible.toJSValue(in: context)
            }

            // Foundation collections box Swift primitives as NSString/NSNumber.
            if let string = value as? String { return string.toJSValue(in: context) }
            if let number = value as? NSNumber {
                if CFGetTypeID(number) == CFBooleanGetTypeID() {
                    return number.boolValue.toJSValue(in: context)
                }
                return number.doubleValue.toJSValue(in: context)
            }
            return NSNull().toJSValue(in: context)
        }
    }
}

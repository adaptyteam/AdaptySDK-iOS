//
//  JSValue+SafeConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 07.09.2026.
//

import Foundation
import JavaScriptCore

extension JSValue {

    static func safeConvert(from value: Any?, context: JSContext, maxDepth: Int = 128) -> JSValue {
        guard let value else { return JSValue(nullIn: context) }
        return safeConvert(from: value, context: context, maxDepth: maxDepth)
    }

    static func safeConvert(from value: Any, context: JSContext, maxDepth: Int = 128) -> JSValue {
        var converter = SafeConverter(context: context, maxDepth: maxDepth)
        return converter.convert(value)
    }

    private struct SafeConverter {
        let context: JSContext
        let maxDepth: Int
        private var ancestors: Set<ObjectIdentifier> = []
        private lazy var nullValue = JSValue(nullIn: context)!

        init(context: JSContext, maxDepth: Int) {
            self.context = context
            self.maxDepth = maxDepth
        }

        mutating func convert(_ value: Any, depth: Int = 0) -> JSValue {
            guard depth <= maxDepth else { return nullValue }

            let mirror = Mirror(reflecting: value)
            if mirror.displayStyle == .optional {
                guard let wrapped = mirror.children.first?.value else {
                    return nullValue
                }
                return convert(wrapped, depth: depth + 1)
            }

            if value is NSNull { return nullValue }

            // CF access avoids recursively bridging cyclic Foundation collections into Swift.
            if let array = value as? NSArray {
                let identity = ObjectIdentifier(array)
                guard ancestors.insert(identity).inserted else { return nullValue }
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
                guard ancestors.insert(identity).inserted else { return nullValue }
                defer { ancestors.remove(identity) }

                let container = unsafeBitCast(dictionary, to: CFDictionary.self)
                let count = CFDictionaryGetCount(container)
                var entries: [(String, AnyObject)] = []
                entries.reserveCapacity(count)
                do {
                    var keys = [UnsafeRawPointer?](repeating: nil, count: count)
                    var values = [UnsafeRawPointer?](repeating: nil, count: count)
                    CFDictionaryGetKeysAndValues(container, &keys, &values)
                    for index in 0..<count {
                        let key = Unmanaged<AnyObject>.fromOpaque(keys[index]!).takeUnretainedValue()
                        guard let name = key as? String else { return nullValue }
                        let element = Unmanaged<AnyObject>.fromOpaque(values[index]!).takeUnretainedValue()
                        entries.append((name, element))
                    }
                }
                let result = JSValue(newObjectIn: context)!
                guard !entries.isEmpty else { return result }
                let descriptor = JSValue(object: [
                    JSPropertyDescriptorWritableKey: true,
                    JSPropertyDescriptorEnumerableKey: true,
                    JSPropertyDescriptorConfigurableKey: true,
                ], in: context)!
                for (name, element) in entries {
                    let converted = convert(element, depth: depth + 1)
                    descriptor.setValue(converted, forProperty: JSPropertyDescriptorValueKey)
                    result.defineProperty(name, descriptor: descriptor)
                }
                return result
            }

            if let convertible = value as? any JSValueConvertable {
                return convertible.toJSValue(in: context)
            }

            // Swift numeric types without protocol conformance can still bridge to NSNumber.
            if let number = value as? NSNumber {
                return number.toJSValue(in: context)
            }
            return nullValue
        }
    }
}

//
//  VC.Value.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import AdaptyCodable
import Foundation

extension VC {
    struct Value: JSValueConvertable {
        let wrapped: any JSValueConvertable

        init(_ value: any JSValueConvertable) {
            if let value = value as? Self {
                self = value
            } else {
                wrapped = value
            }
        }
    }
}

extension JSValueConvertable {
    var isNil: Bool {
        if let value = self as? VC.Value {
            return  AdaptyCodable.isNil(value.wrapped)
        }
        return AdaptyCodable.isNil(self)
    }

    var isArray: Bool {
        if let value = self as? VC.Value {
            return value.wrapped is [any JSValueConvertable]
        }
        return self is [any JSValueConvertable]
    }

    var isObject: Bool {
        if let value = self as? VC.Value {
            return value.wrapped is [String: any JSValueConvertable]
        }
        return self is [String: any JSValueConvertable]
    }

    var asArray: [any JSValueConvertable]? {
        if let value = self as? VC.Value {
            return value.wrapped as? [any JSValueConvertable]
        }
        return self as? [any JSValueConvertable]
    }

    var asObject: [String: any JSValueConvertable]? {
        if let value = self as? VC.Value {
            return value.wrapped as? [String: any JSValueConvertable]
        }
        return self as? [String: any JSValueConvertable]
    }
}

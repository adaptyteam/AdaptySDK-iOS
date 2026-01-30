//
//  VS.SetterParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.01.2026.
//

import Foundation
import JavaScriptCore

extension VS {
    struct SetterParameters<T: JSValueConvertable>: Sendable, Hashable {
        let screenInstance: ScreenInstance
        let name: String
        let value: T
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

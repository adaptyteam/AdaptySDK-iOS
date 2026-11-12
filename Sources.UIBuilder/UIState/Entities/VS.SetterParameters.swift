//
//  VS.SetterParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.01.2026.
//

import Foundation
import JavaScriptCore

extension VS {
    struct SetterParameters<T: JSValueConvertable> {
        let screenInstance: ScreenInstance
        let name: String
        let value: T
    }
}

extension VS.SetterParameters: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setValue(name, forProperty: "name")
        object.setValue(value.toJSValue(in: context), forProperty: "value")
        object.setValue(screenInstance.toJSValue(in: context), forProperty: "_screen")
        return object
    }
}

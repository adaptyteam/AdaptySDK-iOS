//
//  VS.JSState+setConstants.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 04.05.2026.
//

import Foundation
import JavaScriptCore

extension VS.JSState {
    @inlinable
    static func setEnvironmentConstants(_ config: AdaptyUIConfiguration, in context: JSContext) {
        guard let env = config.environmentObject(in: context) else { return }
        let global: JSValue = context.globalObject

        let objectClass = context.objectForKeyedSubscript("Object")
        objectClass?.invokeMethod("freeze", withArguments: [env])

//        #if DEBUG
//        global.setValue(env, forProperty: "SDKEnv")
//        #else
        if let objectClass, let descriptor = JSValue(newObjectIn: context) {
            descriptor.setValue(env, forProperty: "value")
            descriptor.setValue(false, forProperty: "writable")
            descriptor.setValue(false, forProperty: "configurable")
            descriptor.setValue(false, forProperty: "enumerable")
            objectClass.invokeMethod("defineProperty", withArguments: [global, "SDKEnv", descriptor])
        }
//        #endif
    }

    @inlinable
    static func setProductConstants(_ products: [VC.FlowConstants.ProductConstants], final: Bool, in context: JSContext) {
        guard products.isNotEmpty else { return }
        let global: JSValue = context.globalObject

        let products = VC.AnyValue(Dictionary(products.map { ($0.id, VC.AnyValue($0.values)) }, uniquingKeysWith: { first, _ in first }))
            .toJSValue(in: context)

        let objectClass = context.objectForKeyedSubscript("Object")
        objectClass?.invokeMethod("freeze", withArguments: [products])

        if let objectClass, let descriptor = JSValue(newObjectIn: context) {
            descriptor.setValue(products, forProperty: "value")
            descriptor.setValue(false, forProperty: "writable")
            descriptor.setValue(!final, forProperty: "configurable")
            descriptor.setValue(false, forProperty: "enumerable")
            objectClass.invokeMethod("defineProperty", withArguments: [global, "SDKProducts", descriptor])
        }
    }
}

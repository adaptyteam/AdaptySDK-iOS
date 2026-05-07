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
        guard
            let global = context.globalObject,
            let env = config.environmentObject(in: context)
        else { return }

        let objectClass = context.objectForKeyedSubscript("Object")
        objectClass?.invokeMethod("freeze", withArguments: [env])

        #if DEBUG
        global.setObject(env, forKeyedSubscript: "SDKEnv" as NSString)
        #else
        if let objectClass, let descriptor = JSValue(newObjectIn: context) {
            descriptor.setObject(env, forKeyedSubscript: "value" as NSString)
            descriptor.setObject(false, forKeyedSubscript: "writable" as NSString)
            descriptor.setObject(false, forKeyedSubscript: "configurable" as NSString)
            descriptor.setObject(false, forKeyedSubscript: "enumerable" as NSString)
            objectClass.invokeMethod("defineProperty", withArguments: [global, "SDKEnv", descriptor])
        }
        #endif
    }

    @inlinable
    static func setProductConstants(_ products: [VC.FlowConstants.ProductConstants], in context: JSContext) {
        guard
            products.isNotEmpty,
            let global = context.globalObject
        else { return }

        let products = VC.AnyValue(Dictionary(products.map { ($0.id, VC.AnyValue($0.values)) }, uniquingKeysWith: { first, _ in first }))
            .toJSValue(in: context)

        let objectClass = context.objectForKeyedSubscript("Object")
        objectClass?.invokeMethod("freeze", withArguments: [products])
        #if DEBUG
        global.setObject(products, forKeyedSubscript: "SDKProducts" as NSString)
        #else
        if let objectClass, let descriptor = JSValue(newObjectIn: context) {
            descriptor.setObject(products, forKeyedSubscript: "value" as NSString)
            descriptor.setObject(false, forKeyedSubscript: "writable" as NSString)
            descriptor.setObject(false, forKeyedSubscript: "configurable" as NSString)
            descriptor.setObject(false, forKeyedSubscript: "enumerable" as NSString)
            objectClass.invokeMethod("defineProperty", withArguments: [global, "SDKProducts", descriptor])
        }
        #endif
    }
}

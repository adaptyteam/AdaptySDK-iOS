//
//  VS.RestorePurchasesResponse.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 07.05.2026.
//

import JavaScriptCore

extension VS {
    struct RestorePurchasesResponse: Sendable, Hashable {
        let result: RestorePurchasesResult
    }

    enum RestorePurchasesResult: String, VC.Value {
        case fail
        case success
    }
}

extension VS.RestorePurchasesResult: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        rawValue.toJSValue(in: context)
    }
}

extension VS.RestorePurchasesResponse: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setObject(result.toJSValue(in: context), forKeyedSubscript: "result" as NSString)
        return object
    }
}

//
//  VS.PurchaseResponse.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 07.05.2026.
//

import Foundation
import JavaScriptCore

extension VS {
    struct PurchaseResponse: Sendable {
        let productId: String
        let result: PurchaseResult
    }

    enum PurchaseResult: String, VC.Value {
        case fail
        case userCanceled
        case success
        case pending
    }
}

extension VS.PurchaseResult: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        rawValue.toJSValue(in: context)
    }
}

extension VS.PurchaseResponse: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setObject(productId.toJSValue(in: context), forKeyedSubscript: "productId" as NSString)
        object.setObject(result.toJSValue(in: context), forKeyedSubscript: "result" as NSString)
        return object
    }
}

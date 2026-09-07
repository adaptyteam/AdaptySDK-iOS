//
//  VS.PurchaseResponse.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 07.05.2026.
//

import Foundation
import JavaScriptCore

package extension VS {
    struct PurchaseResponse: Sendable {
        let productId: String
        let result: PurchaseResult
    }

    enum PurchaseResult: String {
        case fail
        case userCanceled
        case success
        case pending
    }
}

extension VS.PurchaseResponse: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setValue(productId, forProperty: "productId")
        object.setValue(result.rawValue, forProperty: "result")
        return object
    }
}

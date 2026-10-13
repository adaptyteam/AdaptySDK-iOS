//
//  VS.RestorePurchasesResponse.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 07.05.2026.
//

import JavaScriptCore

package extension VS {
    struct RestorePurchasesResponse: Sendable {
        let result: RestorePurchasesResult
    }

    enum RestorePurchasesResult: String {
        case fail
        case success
    }
}

extension VS.RestorePurchasesResponse: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setValue(result.rawValue, forProperty: "result")
        return object
    }
}

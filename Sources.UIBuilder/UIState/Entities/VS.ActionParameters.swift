//
//  VS.ActionParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.01.2026.
//

import Foundation
import JavaScriptCore

extension VS {
    struct ActionParameters: Sendable, Hashable {
        let screenInstance: ScreenInstance
        let params: [String: VC.Action.Parameter]?
    }
}

extension VS.ActionParameters: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object =
            if let params {
                params.toJSValue(in: context)
            } else {
                JSValue(newObjectIn: context)!
            }
        object.setObject(screenInstance.toJSValue(in: context), forKeyedSubscript: "_screen" as NSString)
        return object
    }
}

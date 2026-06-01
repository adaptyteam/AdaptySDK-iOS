//
//  VS.TimerResponse.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2026.
//

import Foundation
import JavaScriptCore

extension VS {
    struct TimerResponse: Sendable {
        let timerId: String?
    }
}

extension VS.TimerResponse: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setObject(timerId?.toJSValue(in: context), forKeyedSubscript: "timerId" as NSString)
        return object
    }
}

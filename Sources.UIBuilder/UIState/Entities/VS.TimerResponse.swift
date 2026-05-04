//
//  VS.TimerResponse.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2026.
//

import Foundation
import JavaScriptCore

package extension VS {
    struct TimerResponse: Sendable, Hashable {
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


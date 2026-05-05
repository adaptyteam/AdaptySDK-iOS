//
//  VS.SDKEvent.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 05.05.2026.
//

import JavaScriptCore

extension VS {
    enum SDKEvent: String, VC.Value {
        case productLoaded
    }
}

extension VS.SDKEvent: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        rawValue.toJSValue(in: context)
    }
}


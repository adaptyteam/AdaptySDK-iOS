//
//  VS.CustomElementInstance.swift
//  AdaptyUIBuilder
//
//  Created by Adapty on 03.09.2026.
//

import Foundation
import JavaScriptCore

extension VS {
    struct CustomElementInstance: Identifiable {
        let id: String
        let type: String
    }
}

extension VS.CustomElementInstance: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setObject(id, forKeyedSubscript: "id" as NSString)
        object.setObject(type, forKeyedSubscript: "type" as NSString)
        return object
    }
}

extension VC.CustomElement {
    var instance: VS.CustomElementInstance {
        .init(id: id, type: type)
    }
}

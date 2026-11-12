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

        var debugString: String {
            "{id: \(String(reflecting: id)), type: \(String(reflecting: type))}"
        }
    }
}

extension VS.CustomElementInstance: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setValue(id, forProperty: "id")
        object.setValue(type, forProperty: "type")
        return object
    }
}

extension VC.CustomElement {
    var instance: VS.CustomElementInstance {
        .init(id: id, type: type)
    }
}

//
//  VS.ScreenInstance.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.01.2026.
//

import Foundation
import JavaScriptCore

extension VS {
    struct ScreenInstance: Identifiable {
        let id: String
        let navigatorId: String
        let configuration: VC.Screen
        let contextPath: [String]

        var debugString: String {
            "{instanceId: \(String(reflecting: id)), navigatorId: \(String(reflecting: navigatorId)), type: \(String(reflecting: configuration.id))}"
        }
    }
}

extension VS.ScreenInstance: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setValue(id, forProperty: "instanceId")
        object.setValue(navigatorId, forProperty: "navigatorId")
        object.setValue(configuration.id, forProperty: "type")
        object.setValue(contextPath.joined(separator: "."), forProperty: "contextPath")
        return object
    }
}

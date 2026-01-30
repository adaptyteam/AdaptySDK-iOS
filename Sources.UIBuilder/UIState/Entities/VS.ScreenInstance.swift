//
//  VCS.ScreenInstance.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.01.2026.
//

import Foundation
import JavaScriptCore

package extension VS {
    struct ScreenInstance: Sendable, Hashable {
        let id: String
        let navigatorId: String
        let configuration: VC.Screen
        let contextPath: [String]
    }
}

extension VS.ScreenInstance: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setObject(id, forKeyedSubscript: "instanceId" as NSString)
        object.setObject(navigatorId, forKeyedSubscript: "navigatorId" as NSString)
        object.setObject(configuration.id, forKeyedSubscript: "type" as NSString)
        object.setObject(contextPath.joined(separator: "."), forKeyedSubscript: "contextPath" as NSString)
        return object
    }
}

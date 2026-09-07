//
//  VS.AppMessage.swift
//  AdaptyUIBuilder
//
//  Created by Adapty on 03.09.2026.
//

import Foundation
import JavaScriptCore

extension VS {
    struct AppMessage: Identifiable {
        let id: UUID
        let type: Kind
        let screenInstance: ScreenInstance?
        let customElement: CustomElementInstance?
        let message: [String: any JSValueConvertable]

        init(screenInstance: ScreenInstance, customElement: VC.CustomElement, message: [String: any JSValueConvertable]) {
            self.init(
                screenInstance: screenInstance,
                customElement: customElement.instance,
                message: message
            )
        }

        init(screenInstance: ScreenInstance, customElement: CustomElementInstance, message: [String: any JSValueConvertable]) {
            id = UUID()
            type = .customElement
            self.screenInstance = screenInstance
            self.customElement = customElement
            self.message = message
        }

        init(message: [String: any VC.Value]) {
            id = UUID()
            type = .app
            screenInstance = nil
            customElement = nil
            self.message = message
        }
    }
}

extension VS.AppMessage {
    enum Kind: String, Sendable {
        case app
        case customElement = "custom_element"
    }
}

extension VS.AppMessage: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let meta = JSValue(newObjectIn: context)!
        meta.setObject(id.uuidString, forKeyedSubscript: "id" as NSString)
        meta.setObject(type.rawValue, forKeyedSubscript: "type" as NSString)

        if let customElement {
            meta.setObject(customElement.toJSValue(in: context), forKeyedSubscript: "element" as NSString)
        }
        if let screenInstance {
            meta.setObject(screenInstance.toJSValue(in: context), forKeyedSubscript: "screen" as NSString)
        }

        let object = JSValue(newObjectIn: context)!
        for (key, value) in message {
            object.setObject(value.toJSValue(in: context), forKeyedSubscript: key as NSString)
        }
        object.setObject(meta, forKeyedSubscript: "_message" as NSString)
        return object
    }
}

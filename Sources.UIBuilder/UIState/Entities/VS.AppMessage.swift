//
//  VS.AppMessage.swift
//  AdaptyUIBuilder
//
//  Created by Adapty on 03.09.2026.
//

import CoreFoundation
import Foundation
import JavaScriptCore

extension VS {
    struct AppMessage: Identifiable {

        enum Kind: String {
            case app = "app_msg"
            case customElement = "custom_element_msg"
        }

        let id: String
        let type: Kind
        let screenInstance: ScreenInstance?
        let elementInstance: CustomElementInstance?
        let payload: [String: Any]

        init(id: String, screenInstance: ScreenInstance, customElement: VC.CustomElement, payload: [String: Any]) throws {
            try self.init(
                id: id,
                type: .customElement,
                screenInstance: screenInstance,
                elementInstance: customElement.instance,
                payload: payload
            )
        }

        init(id: String, screenInstance: ScreenInstance, elementInstance: CustomElementInstance, payload: [String: Any]) throws {
            try self.init(
                id: id,
                type: .customElement,
                screenInstance: screenInstance,
                elementInstance: elementInstance,
                payload: payload
            )
        }

        init(id: String, payload: [String: Any]) throws {
            try self.init(
                id: id,
                type: .app,
                screenInstance: nil,
                elementInstance: nil,
                payload: payload
            )
        }

        private init(
            id: String,
            type: Kind,
            screenInstance: ScreenInstance?,
            elementInstance: CustomElementInstance?,
            payload: [String: Any]
        ) throws {
            self.id = id
            self.type = type
            self.screenInstance = screenInstance
            self.elementInstance = elementInstance
            self.payload = payload
        }

        var debugString: String {
            var fields = [String]()
            if let screen = screenInstance {
                fields.append("screen: \(screen.debugString)")
            }
            if let element = elementInstance {
                fields.append("element: \(element.debugString)")
            }
            let message = payload.sorted { $0.key < $1.key }
                .map { "\(String(reflecting: $0.key)): \(String(reflecting: $0.value))" }
                .joined(separator: ", ")
            fields.append("message: {\(message)}")
            return fields.joined(separator: ", ")
        }
    }
}

extension VS.AppMessage: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setValue(id, forProperty: "id")
        object.setValue(type.rawValue, forProperty: "name")
        if let screenInstance {
            object.setValue(screenInstance.toJSValue(in: context), forProperty: "screen")
        }
        if let elementInstance {
            object.setValue(elementInstance.toJSValue(in: context), forProperty: "element")
        }
        object.setValue(JSValue.safeConvert(from: payload, context: context), forProperty: "payload")
        return object
    }
}

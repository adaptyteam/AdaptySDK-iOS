//
//  VS.ShowAlertDialogParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.03.2026.
//

import Foundation
import JavaScriptCore

package extension VS {
    struct ShowAlertDialogParameters: Sendable, Hashable {
        let title: String?
        let message: String?
        let buttons: [Button]
    }

    struct ShowAlertDialogParametersResponse: Sendable, Hashable {
        let actionId: String?
    }
}

extension VS.ShowAlertDialogParameters {
    struct Button: Sendable, Hashable {
        let title: String?
        let style: ActionStyle
        let actionId: String?
    }
}

extension VS.ShowAlertDialogParameters {
    enum ActionStyle: String {
        case `default`
        case cancel
        case destructive
    }
}

extension VS.ShowAlertDialogParametersResponse: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setObject(actionId.toJSValue(in: context), forKeyedSubscript: "actionId" as NSString)
        return object
    }
}

extension VS.ShowAlertDialogParameters {
    static func fromDictionary(_ dict: [String: Any]) -> Self {
        let title = dict["title"] as? String
        let message = dict["message"] as? String

        var buttons = [Button]()
        if let actionDicts = dict["actions"] as? [[String: Any]] {
            for actionDict in actionDicts {
                buttons.append(Button.fromDictionary(actionDict))
            }
        }

        return .init(
            title: title,
            message: message,
            buttons: buttons
        )
    }
}

extension VS.ShowAlertDialogParameters.Button {
    static func fromDictionary(_ dict: [String: Any]) -> Self {
        let title = dict["title"] as? String
        let actionId = (dict["actionId"] as? String) ?? title
        let style: VS.ShowAlertDialogParameters.ActionStyle =
            if let styleString = dict["style"] as? String,
            let value = VS.ShowAlertDialogParameters.ActionStyle(rawValue: styleString) {
                value
            } else {
                .default
            }

        return .init(
            title: title,
            style: style,
            actionId: actionId
        )
    }
}


//
//  VS.ShowAlertDialogParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.03.2026.
//

import Foundation
import JavaScriptCore

extension VS {
    struct ShowAlertDialogParameters: Sendable {
        let title: StringIdentifierOrText?
        let message: StringIdentifierOrText?
        let buttons: [Button]
    }

    struct ShowAlertDialogResponse: Sendable {
        let actionId: String?
    }
}

extension VS.ShowAlertDialogParameters {
    struct Button: Sendable {
        let title: VS.StringIdentifierOrText?
        let style: ActionStyle
        let actionId: String?
    }
}

extension VS.ShowAlertDialogParameters {
    enum ActionStyle: String, Hashable {
        case `default`
        case cancel
        case destructive
    }
}

extension VS.ShowAlertDialogResponse: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setValue(actionId.toJSValue(in: context), forProperty: "actionId")
        return object
    }
}

extension VS.ShowAlertDialogParameters {
    static func fromDictionary(_ dict: [AnyHashable: Any]) -> Self {
        let title = dict["title"] as? String
        let titleStringId = dict["titleStringId"] as? String
        let message = dict["message"] as? String
        let messageStringId = dict["messageStringId"] as? String

        var buttons = [Button]()
        if let actionDicts = dict["actions"] as? [[String: Any]] {
            for actionDict in actionDicts {
                buttons.append(Button.fromDictionary(actionDict))
            }
        }

        return .init(
            title: .init(stringId: titleStringId, text: title),
            message: .init(stringId: messageStringId, text: message),
            buttons: buttons
        )
    }
}

extension VS.ShowAlertDialogParameters.Button {
    static func fromDictionary(_ dict: [String: Any]) -> Self {
        let title = dict["title"] as? String
        let titleStringId = dict["titleStringId"] as? String
        let actionId = (dict["actionId"] as? String) ?? title
        let style: VS.ShowAlertDialogParameters.ActionStyle =
            if let styleString = dict["style"] as? String,
            let value = VS.ShowAlertDialogParameters.ActionStyle(rawValue: styleString) {
                value
            } else {
                .default
            }

        return .init(
            title: .init(stringId: titleStringId, text: title),
            style: style,
            actionId: actionId
        )
    }
}

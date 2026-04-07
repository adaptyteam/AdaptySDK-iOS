//
//  VS.JSActionDispatcher.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.12.2025.
//

import AdaptyLogger
import Foundation
import JavaScriptCore

extension VS {
    final class JSActionDispatcher: NSObject {
        private weak var handler: AdaptyUIActionHandler?
        private let configuration: AdaptyUIConfiguration

        init(
            _ handler: AdaptyUIActionHandler?,
            _ configuration: AdaptyUIConfiguration
        ) {
            self.configuration = configuration
            self.handler = handler
        }
    }
}

@objc protocol JSActionBridge: JSExport {
    func log(_ params: JSValue)
    func openUrl(_ params: JSValue)
    func userCustomAction(_ params: JSValue)
    func purchaseProduct(_ params: JSValue)
    func webPurchaseProduct(_ params: JSValue)
    func restorePurchases()
    func closeAll()
    func onSelectProduct(_ params: JSValue)
    func openScreen(_ params: JSValue)
    func closeScreen(_ params: JSValue)
    func changeFocus(_ params: JSValue)
    func setTimer(_ params: JSValue)
    func moveScroll(_ params: JSValue)
    func showAppRate(_ params: JSValue)
    func showAlertDialog(_ params: JSValue)
    func showRequestPermission(_ params: JSValue)
    func sendEvents(_ params: JSValue)
}

extension VS.JSActionDispatcher {
    func execute(_: VC.Action, in _: JSContext) -> Bool {
        false
    }
}

extension VS.JSActionDispatcher: JSActionBridge {
    func log(_ params: JSValue) {
        var message = params.toString() ?? "null"
        var level = AdaptyLogger.Level.debug

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            if let msg = dict["message"] as? String { message = msg }
            if let lvl = dict["level"] as? String {
                level = switch lvl {
                case "error": .error
                case "warn": .warn
                case "info": .info
                case "verbose": .verbose
                default: .debug
                }
            }
        }

        Log.js.message(message, withLevel: level)
    }

    func openUrl(_ params: JSValue) {
        var stringId: String?
        var url: URL?
        var openIn = VC.Action.WebOpenInParameter.browserOutApp

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            stringId = dict["stringId"] as? String
            url = (dict["url"] as? String).flatMap(URL.init)
            openIn = (dict["openIn"] as? String).flatMap(VC.Action.WebOpenInParameter.init) ?? openIn
        }

        if let url {
            handler?.openUrl(url: url, openIn: openIn)
            return
        }

        if let stringId {
            handler?.openUrl(stringId: stringId, openIn: openIn)
            return
        }

        Log.viewState.error(#"SDK.openUrl: required parameter "url" or "stringId" is missing or not is URL"#)
    }

    func userCustomAction(_ params: JSValue) {
        var userCustomId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            userCustomId = dict["userCustomId"] as? String
        }

        guard let userCustomId else {
            Log.viewState.error(#"SDK.userCustomAction: required parameter "userCustomId" is missing"#)
            return
        }
        handler?.userCustomAction(id: userCustomId)
    }

    func purchaseProduct(_ params: JSValue) {
        var productId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            productId = dict["productId"] as? String
        }

        guard let productId else {
            Log.viewState.error(#"SDK.purchaseProduct: required parameter "productId" is missing"#)
            return
        }

        handler?.purchaseProduct(productId: productId, service: .storeKit)
    }

    func webPurchaseProduct(_ params: JSValue) {
        var productId: String?
        var openIn = VC.Action.WebOpenInParameter.browserOutApp

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            productId = dict["productId"] as? String
            openIn = (dict["openIn"] as? String).flatMap(VC.Action.WebOpenInParameter.init) ?? openIn
        }

        guard let productId else {
            Log.viewState.error(#"SDK.webPurchaseProduct: required parameter "productId" is missing"#)
            return
        }

        handler?.purchaseProduct(productId: productId, service: .openWebPaywall(openIn: openIn))
    }

    func restorePurchases() {
        handler?.restorePurchases()
    }

    func closeAll() {
        handler?.closeAll()
    }

    func onSelectProduct(_ params: JSValue) {
        var productId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            productId = dict["productId"] as? String
        }

        guard let productId else {
            Log.viewState.error(#"SDK.onSelectProduct: required parameter "productId" is missing"#)
            return
        }

        handler?.selectProduct(productId: productId)
    }

    func openScreen(_ params: JSValue) {
        var instanceId: String?
        var screenType: VC.ScreenType?
        var contextPath: [String]?
        var navigatorId: String?
        var transitionId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            instanceId = dict["instanceId"] as? String
            navigatorId = dict["navigatorId"].flatMap { $0 as? String }
            transitionId = dict["transitionId"] as? String
            screenType = dict["type"] as? String
            if let path = dict["contextPath"] as? String {
                contextPath = path.split(separator: ".").map(String.init)
            }
        }

        guard let screenType else {
            Log.viewState.error(#"SDK.openScreen: required parameter "type" is missing"#)
            return
        }
        guard let configuration = configuration.screens[screenType] else {
            Log.viewState.error(#"SDK.openScreen: not found screen type: \#(screenType)"#)
            return
        }
        guard let instanceId else {
            Log.viewState.error(#"SDK.openScreen: required parameter "instanceId" is missing"#)
            return
        }

        guard let transitionId else {
            Log.viewState.error(#"SDK.openScreen: required parameter "transitionId" is missing"#)
            return
        }

        handler?.openScreen(
            instance: .init(
                id: instanceId,
                navigatorId: navigatorId ?? "default",
                configuration: configuration,
                contextPath: contextPath ?? []
            ),
            transitionId: transitionId
        )
    }

    func closeScreen(_ params: JSValue) {
        var navigatorId: String?
        var transitionId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            navigatorId = dict["navigatorId"] as? String
            transitionId = dict["transitionId"] as? String
        }

        handler?.closeScreen(
            navigatorId: navigatorId ?? "default",
            transitionId: transitionId ?? VC.Navigator.AppearanceTransition.onDisappearKey
        )
    }

    func changeFocus(_ params: JSValue) {
        var focusId: String?
        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            focusId = dict["id"] as? String
        }

        handler?.changeFocus(
            id: focusId
        )
    }

    func setTimer(_ params: JSValue) {
        var timerId: String?
        var endAt: Date?
        var duration: Double?
        var behavior: VC.SetTimerBehavior?

        var callback: VS.JSAction?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            timerId = dict["id"] as? String

            if let value = dict["endAt"] as? Double {
                endAt = Date(timeIntervalSince1970: value / 1000)
            }

            duration = dict["duration"] as? Double

            if let value = dict["behavior"] as? String {
                behavior = .init(rawValue: value)
            }

            callback = VS.JSAction(from: params.forProperty("callback"))
        }

        guard let timerId else {
            Log.viewState.error(#"SDK.setTimer: required parameter "timerId" is missing"#)
            return
        }

        if let endAt {
            handler?.setTimer(id: timerId, endAt: endAt, callback: callback)
            return
        }

        if let duration {
            handler?.setTimer(id: timerId, duration: duration, behavior: behavior ?? .continue, callback: callback)
            return
        }
    }

    func moveScroll(_ params: JSValue) {
        var instanceId: String?
        var kind: VC.ScrollKind?
        var value: VC.ScrollValue?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            instanceId = dict["instanceId"] as? String

            if let v = dict["kind"] as? String {
                kind = .init(rawValue: v)
            }

            if let v = dict["value"] as? String {
                value = .init(rawValue: v)
            }
        }

        guard let instanceId else {
            Log.viewState.error(#"SDK.moveScroll: required parameter "instanceId" is missing"#)
            return
        }

        guard let kind else {
            Log.viewState.error(#"SDK.moveScroll: required parameter "kind" is missing or corupted"#)
            return
        }

        guard let value else {
            Log.viewState.error(#"SDK.moveScroll: required parameter "value" is missing or corupted"#)
            return
        }

        handler?.moveScroll(
            instanceId: instanceId,
            kind: kind,
            value: value
        )
    }

    func showAppRate(_: JSValue) {
        handler?.showAppRate()
    }

    func showAlertDialog(_ params: JSValue) {
        guard params.isObject, let dict = params.toDictionary() as? [String: Any] else {
            Log.viewState.error(#"SDK.showAlertDialog: corupted params"#)
            return
        }

        handler?.showAlertDialog(
            params: VS.ShowAlertDialogParameters.fromDictionary(dict),
            callback: VS.JSAction(from: params.forProperty("callback"))
        )
    }

    func showRequestPermission(_ params: JSValue) {
        guard params.isObject, let dict = params.toDictionary() as? [String: Any] else {
            Log.viewState.error(#"SDK.showRequestPermission: corupted params"#)
            return
        }

        handler?.showRequestPermission(
            params: VS.ShowRequestPermissionParameters.fromDictionary(dict),
            callback: VS.JSAction(from: params.forProperty("callback"))
        )
    }

    func sendEvents(_ params: JSValue) {
        var instanceId: String?
        var events: [String]?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            instanceId = dict["instanceId"] as? String

            if let v = dict["events"] as? [String] {
                events = v
            }
        }

        guard let events, events.isNotEmpty else {
            Log.viewState.error(#"SDK.sendEvents: required parameter "events" is missing or corupted"#)
            return
        }

        handler?.sendEvents(instanceId: instanceId, eventIds: events)
    }
}


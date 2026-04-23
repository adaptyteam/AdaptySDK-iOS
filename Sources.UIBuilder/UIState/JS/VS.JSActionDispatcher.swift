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

extension VS.JSActionDispatcher {
    @inlinable
    func log(_ params: [AnyHashable: Any]?) {
        var message = "null"
        var level = AdaptyLogger.Level.debug

        if let params {
            if let msg = params["message"] as? String { message = msg }
            if let lvl = params["level"] as? String {
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

    @inlinable
    func openUrl(_ params: [AnyHashable: Any]?) {
        guard let params else {
            Log.viewState.error(#"SDK.openUrl: corupted params"#)
            return
        }

        let openIn = (params["openIn"] as? String).flatMap(VC.Action.WebOpenInParameter.init) ?? .browserOutApp

        if let url = (params["url"] as? String).flatMap(URL.init) {
            handler?.openUrl(url: url, openIn: openIn)
            return
        }

        if let stringId = params["stringId"] as? String {
            handler?.openUrl(stringId: stringId, openIn: openIn)
            return
        }

        Log.viewState.error(#"SDK.openUrl: required parameter "url" or "stringId" is missing or not is URL"#)
    }

    @inlinable
    func userCustomAction(_ params: [AnyHashable: Any]?) {
        guard let userCustomId = params?["userCustomId"] as? String else {
            Log.viewState.error(#"SDK.userCustomAction: required parameter "userCustomId" is missing"#)
            return
        }

        handler?.userCustomAction(id: userCustomId)
    }

    @inlinable
    func purchaseProduct(_ params: [AnyHashable: Any]?) {
        guard let productId = params?["productId"] as? String else {
            Log.viewState.error(#"SDK.purchaseProduct: required parameter "productId" is missing"#)
            return
        }

        handler?.purchaseProduct(productId: productId, service: .storeKit)
    }

    @inlinable
    func webPurchaseProduct(_ params: [AnyHashable: Any]?) {
        guard let params else {
            Log.viewState.error(#"SDK.webPurchaseProduct: corupted params"#)
            return
        }

        let openIn = (params["openIn"] as? String).flatMap(VC.Action.WebOpenInParameter.init) ?? .browserOutApp

        guard let productId = params["productId"] as? String else {
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

    @inlinable
    func onSelectProduct(_ params: [AnyHashable: Any]?) {
        guard let productId = params?["productId"] as? String else {
            Log.viewState.error(#"SDK.onSelectProduct: required parameter "productId" is missing"#)
            return
        }

        handler?.selectProduct(productId: productId)
    }

    @inlinable
    func openScreen(_ params: [AnyHashable: Any]?) {
        guard let params else {
            Log.viewState.error(#"SDK.openScreen: corupted params"#)
            return
        }

        let contextPath: [String]? =
            if let path = params["contextPath"] as? String {
                path.split(separator: ".").map(String.init)
            } else {
                nil
            }

        guard let screenType = params["type"] as? String else {
            Log.viewState.error(#"SDK.openScreen: required parameter "type" is missing"#)
            return
        }
        guard let configuration = configuration.screens[screenType] else {
            Log.viewState.error(#"SDK.openScreen: not found screen type: \#(screenType)"#)
            return
        }
        guard let instanceId = params["instanceId"] as? String else {
            Log.viewState.error(#"SDK.openScreen: required parameter "instanceId" is missing"#)
            return
        }

        guard let transitionId = params["transitionId"] as? String else {
            Log.viewState.error(#"SDK.openScreen: required parameter "transitionId" is missing"#)
            return
        }

        handler?.openScreen(
            instance: .init(
                id: instanceId,
                navigatorId: params["navigatorId"].flatMap { $0 as? String } ?? "default",
                configuration: configuration,
                contextPath: contextPath ?? []
            ),
            transitionId: transitionId
        )
    }

    @inlinable
    func closeScreen(_ params: [AnyHashable: Any]?) {
        guard let params else {
            Log.viewState.error(#"SDK.closeScreen: corupted params"#)
            return
        }

        handler?.closeScreen(
            navigatorId: params["navigatorId"] as? String ?? "default",
            transitionId: params["transitionId"] as? String ?? VC.Navigator.AppearanceTransition.onDisappearKey
        )
    }

    @inlinable
    func changeFocus(_ params: [AnyHashable: Any]?) {
        handler?.changeFocus(
            id: params?["id"] as? String
        )
    }

    @inlinable
    func setTimer(_ params: [AnyHashable: Any]?, callback: VS.JSAction?) {
        guard let params else {
            Log.viewState.error(#"SDK.setTimer: corupted params"#)
            return
        }

        let behavior: VS.SetTimerBehavior? =
            if let value = params["behavior"] as? String {
                .init(rawValue: value)
            } else {
                nil
            }

        guard let timerId = params["id"] as? String else {
            Log.viewState.error(#"SDK.setTimer: required parameter "timerId" is missing"#)
            return
        }

        if let endAt = params["endAt"] as? Double {
            handler?.setTimer(id: timerId, endAt: Date(timeIntervalSince1970: endAt / 1000), callback: callback)
            return
        }

        if let duration = params["duration"] as? Double {
            handler?.setTimer(id: timerId, duration: duration, behavior: behavior ?? .continue, callback: callback)
            return
        }
    }

    @inlinable
    func moveScroll(_ params: [AnyHashable: Any]?) {
        guard let params else {
            Log.viewState.error(#"SDK.moveScroll: corupted params"#)
            return
        }

        guard let instanceId = params["instanceId"] as? String else {
            Log.viewState.error(#"SDK.moveScroll: required parameter "instanceId" is missing"#)
            return
        }

        guard let v = params["kind"] as? String,
              let kind = VS.ScrollKind(rawValue: v)
        else {
            Log.viewState.error(#"SDK.moveScroll: required parameter "kind" is missing or corupted"#)
            return
        }

        guard let v = params["value"] as? String,
              let value = VS.ScrollValue(rawValue: v)
        else {
            Log.viewState.error(#"SDK.moveScroll: required parameter "value" is missing or corupted"#)
            return
        }

        handler?.moveScroll(
            instanceId: instanceId,
            kind: kind,
            value: value
        )
    }

    func showAppRate() {
        handler?.showAppRate()
    }

    @inlinable
    func showAlertDialog(_ params: [AnyHashable: Any]?, callback: VS.JSAction?) {
        guard let params else {
            Log.viewState.error(#"SDK.showAlertDialog: corupted params"#)
            return
        }

        handler?.showAlertDialog(
            params: VS.ShowAlertDialogParameters.fromDictionary(params),
            callback: callback
        )
    }

    @inlinable
    func showRequestPermission(_ params: [AnyHashable: Any]?, callback: VS.JSAction?) {
        guard let params else {
            Log.viewState.error(#"SDK.showRequestPermission: corupted params"#)
            return
        }

        handler?.showRequestPermission(
            params: VS.ShowRequestPermissionParameters.fromDictionary(params),
            callback: callback
        )
    }

    @inlinable
    func sendEvents(_ params: [AnyHashable: Any]?) {
        guard let params else {
            Log.viewState.error(#"SDK.sendEvents: corupted params"#)
            return
        }

        let instanceId = params["instanceId"] as? String

        guard let events = params["events"] as? [String], events.isNotEmpty else {
            Log.viewState.error(#"SDK.sendEvents: required parameter "events" is missing or corupted"#)
            return
        }

        handler?.sendEvents(instanceId: instanceId, eventIds: events)
    }

    @inlinable
    func sendAnalyticsEvent(_ params: [String: any Sendable]?) {
        guard let params else {
            Log.viewState.error(#"SDK.sendAnalyticsEvent: corupted params"#)
            return
        }

        guard let name = (params[VS.AnalyticEvent.CodingKeys.name.rawValue] ?? params["name"]) as? String else {
            Log.viewState.error(#"SDK.sendAnalyticsEvent: required parameter "name" is missing or corupted"#)
            return
        }

        handler?.sendAnalyticsEvent(.init(
            name: name,
            params: params
        ))
    }
}


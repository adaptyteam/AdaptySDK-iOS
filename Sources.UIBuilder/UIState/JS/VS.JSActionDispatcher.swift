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

        init(_ handler: AdaptyUIActionHandler?) {
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
}

extension VS.JSActionDispatcher {
    func execute(_ action: VC.Action, in context: JSContext) -> Bool {
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
        var url: URL?
        var openIn = VC.Action.WebOpenInParameter.browserOutApp

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            url = (dict["url"] as? String).flatMap(URL.init)
            openIn = (dict["openIn"] as? String).flatMap(VC.Action.WebOpenInParameter.init) ?? openIn
        }

        guard let url else {
            Log.viewState.warn("SDK.openUrl: required parameter \"url\" is missing or not is URL")
            return
        }
        handler?.openUrl(url: url, openIn: openIn)
    }

    func userCustomAction(_ params: JSValue) {
        var userCustomId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            userCustomId = dict["userCustomId"] as? String
        }

        guard let userCustomId else {
            Log.viewState.warn("SDK.userCustomAction: required parameter \"userCustomId\" is missing")
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
            Log.viewState.warn("SDK.purchaseProduct: required parameter \"productId\" is missing")
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
            Log.viewState.warn("SDK.webPurchaseProduct: required parameter \"productId\" is missing")
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
            Log.viewState.warn("SDK.onSelectProduct: required parameter \"productId\" is missing")
            return
        }
        handler?.selectProduct(productId: productId)
    }

    func openScreen(_ params: JSValue) {
        var instanceId: String?
        var screenType: VC.ScreenType?
        var contextPath: [String]?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            instanceId = dict["instanceId"] as? String
            screenType = dict["type"] as? String
            if let path = dict["contextPath"] as? String {
                contextPath = path.split(separator: ".").map(String.init)
            }
        }

        guard let screenType else {
            Log.viewState.warn("SDK.openScreen: required parameter \"type\" is missing")
            return
        }

        guard let instanceId else {
            Log.viewState.warn("SDK.openScreen: required parameter \"instanceId\" is missing")
            return
        }

        handler?.openScreen(instance: .init(
            id: instanceId,
            type: screenType,
            contextPath: contextPath ?? []
        ))
    }

    func closeScreen(_ params: JSValue) {
        var instanceId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            instanceId = dict["instanceId"] as? String
        }

        guard let instanceId else {
            Log.viewState.warn("SDK.closeScreen: required parameter \"instanceId\" is missing")
            return
        }
        handler?.closeScreen(instanceId: instanceId)
    }
}

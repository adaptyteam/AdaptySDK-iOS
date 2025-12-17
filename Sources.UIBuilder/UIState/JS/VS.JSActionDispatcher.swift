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
    func closeCurrentScreen()
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

        if params.isString {
            url = params.toString().flatMap(URL.init)
        } else if params.isObject, let dict = params.toDictionary() as? [String: Any] {
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

        if params.isString {
            userCustomId = params.toString()
        } else if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            userCustomId = dict["userCustomId"] as? String
        }

        guard let userCustomId else {
            Log.viewState.warn("SDK.userCustomAction: required parameter \"userCustomId\" is missing")
            return
        }
        handler?.userCustomAction(id: userCustomId)
    }

    func purchaseProduct(_ params: JSValue) { // string | productId: string

        var productId: String?

        if params.isString {
            productId = params.toString()
        } else if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            productId = dict["productId"] as? String
        }

        guard let productId else {
            Log.viewState.warn("SDK.purchaseProduct: required parameter \"productId\" is missing")
            return
        }
        handler?.purchaseProduct(productId: productId, service: .storeKit)
    }

    func webPurchaseProduct(_ params: JSValue) { // string | productId: string [, openIn: string]
        var productId: String?
        var openIn = VC.Action.WebOpenInParameter.browserOutApp

        if params.isString {
            productId = params.toString()
        } else if params.isObject, let dict = params.toDictionary() as? [String: Any] {
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

        if params.isString {
            productId = params.toString()
        } else if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            productId = dict["productId"] as? String
        }

        guard let productId else {
            Log.viewState.warn("SDK.onSelectProduct: required parameter \"productId\" is missing")
            return
        }
        handler?.selectProduct(productId: productId)
    }

    func openScreen(_ params: JSValue) { // string | screenId: string
        var screenId: String?

        if params.isString {
            screenId = params.toString()
        } else if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            screenId = dict["screenId"] as? String
        }

        guard let screenId else {
            Log.viewState.warn("SDK.openScreen: required parameter \"screenId\" is missing")
            return
        }
        handler?.openScreen(screenId: screenId)
    }

    func closeCurrentScreen() {
        handler?.closeCurrentScreen()
    }
}

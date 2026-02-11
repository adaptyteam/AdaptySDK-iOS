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
            Log.viewState.error("SDK.openUrl: required parameter \"url\" is missing or not is URL")
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
            Log.viewState.error("SDK.userCustomAction: required parameter \"userCustomId\" is missing")
            return
        }
        handler?.userCustomAction(id: userCustomId)
    }

    func purchaseProduct(_ params: JSValue) {
        var productId: String?
        var paywallId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            productId = dict["productId"] as? String
            paywallId = dict["paywallId"] as? String
        }

        guard let productId else {
            Log.viewState.error("SDK.purchaseProduct: required parameter \"productId\" is missing")
            return
        }

        guard let paywallId else {
            Log.viewState.error("SDK.purchaseProduct: required parameter \"paywallId\" is missing")
            return
        }

        handler?.purchaseProduct(productId: productId, paywallId: paywallId, service: .storeKit)
    }

    func webPurchaseProduct(_ params: JSValue) {
        var productId: String?
        var paywallId: String?
        var openIn = VC.Action.WebOpenInParameter.browserOutApp

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            productId = dict["productId"] as? String
            paywallId = dict["paywallId"] as? String
            openIn = (dict["openIn"] as? String).flatMap(VC.Action.WebOpenInParameter.init) ?? openIn
        }

        guard let productId else {
            Log.viewState.error("SDK.webPurchaseProduct: required parameter \"productId\" is missing")
            return
        }

        guard let paywallId else {
            Log.viewState.error("SDK.purchaseProduct: required parameter \"paywallId\" is missing")
            return
        }

        handler?.purchaseProduct(productId: productId, paywallId: paywallId, service: .openWebPaywall(openIn: openIn))
    }

    func restorePurchases() {
        handler?.restorePurchases()
    }

    func closeAll() {
        handler?.closeAll()
    }

    func onSelectProduct(_ params: JSValue) {
        var productId: String?
        var paywallId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            productId = dict["productId"] as? String
            paywallId = dict["paywallId"] as? String
        }

        guard let productId else {
            Log.viewState.error("SDK.onSelectProduct: required parameter \"productId\" is missing")
            return
        }
        guard let paywallId else {
            Log.viewState.error("SDK.purchaseProduct: required parameter \"paywallId\" is missing")
            return
        }

        handler?.selectProduct(productId: productId, paywallId: paywallId)
    }

    func openScreen(_ params: JSValue) {
        var instanceId: String?
        var screenType: VC.ScreenType?
        var contextPath: [String]?
        var navigatorId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            instanceId = dict["instanceId"] as? String
            navigatorId = dict["navigatorId"].flatMap { $0 as? String }
            screenType = dict["type"] as? String
            if let path = dict["contextPath"] as? String {
                contextPath = path.split(separator: ".").map(String.init)
            }
        }

        guard let screenType else {
            Log.viewState.error("SDK.openScreen: required parameter \"type\" is missing")
            return
        }
        guard let configuration = configuration.screens[screenType] else {
            Log.viewState.error("SDK.openScreen: not found screen type: \(screenType)")
            return
        }
        guard let instanceId else {
            Log.viewState.error("SDK.openScreen: required parameter \"instanceId\" is missing")
            return
        }

        handler?.openScreen(instance: .init(
            id: instanceId,
            navigatorId: navigatorId ?? "default",
            configuration: configuration,
            contextPath: contextPath ?? []
        ))
    }

    func closeScreen(_ params: JSValue) {
        var navigatorId: String?

        if params.isObject, let dict = params.toDictionary() as? [String: Any] {
            navigatorId = dict["navigatorId"] as? String
        }

        handler?.closeScreen(navigatorId: navigatorId ?? "default")
    }
}

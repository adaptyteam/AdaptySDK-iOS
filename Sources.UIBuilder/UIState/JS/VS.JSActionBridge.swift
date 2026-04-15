//
//  VS.JSActionBridge.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.04.2026.
//

import AdaptyLogger
import Foundation
import JavaScriptCore

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
    func showAppRate()
    func showAlertDialog(_ params: JSValue)
    func showRequestPermission(_ params: JSValue)
    func sendEvents(_ params: JSValue)
    func sendAnalyticEvent(_ params: JSValue)
}

extension VS.JSActionDispatcher: JSActionBridge {
    func log(_ params: JSValue) {
        if params.isObject, let dict = params.toDictionary() {
            log(dict)
        } else if let message = params.toString() {
            log(["message": message])
        } else {
            log(nil)
        }
    }

    func openUrl(_ params: JSValue) {
        openUrl(params.isObject ? params.toDictionary() : nil)
    }

    func userCustomAction(_ params: JSValue) {
        userCustomAction(params.isObject ? params.toDictionary() : nil)
    }

    func purchaseProduct(_ params: JSValue) {
        purchaseProduct(params.isObject ? params.toDictionary() : nil)
    }

    func webPurchaseProduct(_ params: JSValue) {
        webPurchaseProduct(params.isObject ? params.toDictionary() : nil)
    }

    func onSelectProduct(_ params: JSValue) {
        onSelectProduct(params.isObject ? params.toDictionary() : nil)
    }

    func openScreen(_ params: JSValue) {
        openScreen(params.isObject ? params.toDictionary() : nil)
    }

    func closeScreen(_ params: JSValue) {
        closeScreen(params.isObject ? params.toDictionary() : nil)
    }

    func changeFocus(_ params: JSValue) {
        changeFocus(params.isObject ? params.toDictionary() : nil)
    }

    func setTimer(_ params: JSValue) {
        guard params.isObject else {
            Log.viewState.error(#"SDK.setTimer: parameter must be object"#)
            return
        }
        setTimer(
            params.toDictionary(),
            callback: VS.JSAction(from: params.forProperty("callback"))
        )
    }

    func moveScroll(_ params: JSValue) {
        moveScroll(params.isObject ? params.toDictionary() : nil)
    }

    func showAlertDialog(_ params: JSValue) {
        guard params.isObject else {
            Log.viewState.error(#"SDK.showAlertDialog: parameter must be object"#)
            return
        }
        showAlertDialog(
            params.toDictionary(),
            callback: VS.JSAction(from: params.forProperty("callback"))
        )
    }

    func showRequestPermission(_ params: JSValue) {
        guard params.isObject else {
            Log.viewState.error(#"SDK.showRequestPermission: parameter must be object"#)
            return
        }
        showRequestPermission(
            params.toDictionary(),
            callback: VS.JSAction(from: params.forProperty("callback"))
        )
    }

    func sendEvents(_ params: JSValue) {
        sendEvents(params.isObject ? params.toDictionary() : nil)
    }

    func sendAnalyticEvent(_ params: JSValue) {
        sendAnalyticEvent(params.isObject ? (params.toDictionary() as? [String: any Sendable]) : nil)
    }
}


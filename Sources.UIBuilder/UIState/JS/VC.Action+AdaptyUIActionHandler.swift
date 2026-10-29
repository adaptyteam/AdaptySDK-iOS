//
//  VC.Action+AdaptyUIActionHandler.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.04.2026.
//

import Foundation

extension VS.JSActionDispatcher {
    @inlinable
    func fastExecute(_ method: String,  params: [String: VC.Value]?) -> Bool {

        switch method {
        case "log":
            log(params?.asSimpleDictionary)
        case "openUrl":
            openUrl(params?.asSimpleDictionary)
        case "userCustomAction":
            userCustomAction(params?.asSimpleDictionary)
        case "purchaseProduct":
            purchaseProduct(params?.asSimpleDictionary, callback: nil)
        case "webPurchaseProduct":
            webPurchaseProduct(params?.asSimpleDictionary, callback: nil)
        case "restorePurchases":
            restorePurchases(callback: nil)
        case "closeAll":
            closeAll()
        case "onSelectProduct":
            onSelectProduct(params?.asSimpleDictionary)
        case "openScreen":
            openScreen(params?.asSimpleDictionary)
        case "closeScreen":
            closeScreen(params?.asSimpleDictionary)
        case "changeFocus":
            changeFocus(params?.asSimpleDictionary)
        case "setTimer":
            setTimer(params?.asSimpleDictionary, callback: nil)
        case "moveScroll":
            moveScroll(params?.asSimpleDictionary)
        case "showAppRate":
            showAppRate()
        case "showAlertDialog":
            showAlertDialog(params?.asSimpleDictionary, callback: nil)
        case "showRequestPermission":
            showRequestPermission(params?.asSimpleDictionary, callback: nil)
        case "sendEvents":
            sendEvents(params?.asSimpleDictionary)
        case "sendAnalyticsEvent":
            sendAnalyticsEvent(params?.asSimpleDictionary)
        default: return false
        }
        return true
    }
}

private extension [String: VC.Value] {
    var asSimpleDictionary: [String: any Sendable]? {
        mapValues(\.actionParameter)
    }
}

private extension VC.Value {
    var actionParameter: any Sendable {
        if wrapped.isNil { return NSNull() }
        if let array = wrapped.asArray {
            return array.map { VC.Value($0).actionParameter }
        }
        if let object = wrapped.asObject {
            return object.mapValues { VC.Value($0).actionParameter }
        }
        return wrapped
    }
}

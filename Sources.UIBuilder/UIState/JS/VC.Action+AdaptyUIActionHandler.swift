//
//  VC.Action+AdaptyUIActionHandler.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.04.2026.
//

extension VS.JSActionDispatcher {
    @inlinable
    func fastExecute(_ action: VC.Action) -> Bool {
        guard
            action.isSDK,
            let method = action.path.count > 1 ? action.path[0] : nil
        else { return false }

        switch method {
        case "log":
            log(action.paramsAsDictionary())
        case "openUrl":
            openUrl(action.paramsAsDictionary())
        case "userCustomAction":
            userCustomAction(action.paramsAsDictionary())
        case "purchaseProduct":
            purchaseProduct(action.paramsAsDictionary())
        case "webPurchaseProduct":
            webPurchaseProduct(action.paramsAsDictionary())
        case "restorePurchases":
            restorePurchases()
        case "closeAll":
            closeAll()
        case "onSelectProduct":
            onSelectProduct(action.paramsAsDictionary())
        case "openScreen":
            openScreen(action.paramsAsDictionary())
        case "closeScreen":
            closeScreen(action.paramsAsDictionary())
        case "changeFocus":
            changeFocus(action.paramsAsDictionary())
        case "setTimer":
            setTimer(action.paramsAsDictionary(), callback: nil)
        case "moveScroll":
            moveScroll(action.paramsAsDictionary())
        case "showAppRate":
            showAppRate()
        case "showAlertDialog":
            showAlertDialog(action.paramsAsDictionary(), callback: nil)
        case "showRequestPermission":
            showRequestPermission(action.paramsAsDictionary(), callback: nil)
        case "sendEvents":
            sendEvents(action.paramsAsDictionary())
        case "sendAnalyticsEvent":
            sendAnalyticsEvent(action.paramsAsDictionary() as? [String: any Sendable])
        default: return false
        }
        return true
    }
}


//
//  AdaptyUIActionHandler.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 15.12.2025.
//

import Foundation

package protocol AdaptyUIActionHandler: AnyObject {
    func openUrl(url: URL, openIn: VC.Action.WebOpenInParameter)
    func openUrl(stringId: String, openIn: VC.Action.WebOpenInParameter)
    func userCustomAction(id: String)
    func purchaseProduct(productId: String, paywallId: String, service: VC.Action.PaymentService)
    func restorePurchases()
    func closeAll()
    func selectProduct(productId: String, paywallId: String)

    func openScreen(instance: VS.ScreenInstance, transitionId: String)
    func closeScreen(navigatorId: String, transitionId: String)

    func registerState(_ state: AdaptyUIState)
    func changeFocus(id: String?)
    func setTimer(id: String, endAt: Date)
    func setTimer(id: String, duration: TimeInterval, behavior: VC.SetTimerBehavior)
    func moveScroll(instanceId: String, kind: VC.ScrollKind, value: VC.ScrollValue)

    func showAlertDialog(params: VS.ShowAlertDialogParameters, callback: VS.JSAction?)
    func showRequestPermission(params: VS.ShowRequestPermissionParameters, callback: VS.JSAction?)
}

package extension VC {
    enum SetTimerBehavior: String, Sendable, Hashable {
        case restart
        case `continue`
        case persisted
        case custom
    }
}

package extension VC {
    enum ScrollKind: String, Sendable, Hashable {
        case content
        case footer
    }

    enum ScrollValue: String, Sendable, Hashable {
        case start
        case end
    }
}


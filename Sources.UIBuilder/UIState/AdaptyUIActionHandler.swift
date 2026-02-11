//
//  AdaptyUIActionHandler.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 15.12.2025.
//

import Foundation

package protocol AdaptyUIActionHandler: AnyObject {
    func openUrl(url: URL, openIn: VC.Action.WebOpenInParameter)
    func userCustomAction(id: String)
    func purchaseProduct(productId: String, paywallId: String, service: VC.Action.PaymentService)
    func restorePurchases()
    func closeAll()
    func selectProduct(productId: String, paywallId: String)

    func openScreen(instance: VS.ScreenInstance, transitionId: String)
    func closeScreen(navigatorId: String, transitionId: String)
}

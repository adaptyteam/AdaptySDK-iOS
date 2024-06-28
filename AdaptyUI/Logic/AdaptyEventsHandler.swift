//
//  AdaptyEventsHandler.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, *)
package class AdaptyEventsHandler { // TODO: make internal
    let logId: String = AdaptyUI.generateLogId()

    // TODO: make private
    var didPerformAction: ((AdaptyUI.Action) -> Void)?
    var didSelectProduct: ((AdaptyPaywallProduct) -> Void)?
    var didStartPurchase: ((AdaptyPaywallProduct) -> Void)?
    var didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void)?
    var didFailPurchase: ((AdaptyPaywallProduct, AdaptyError) -> Void)?
    var didCancelPurchase: ((AdaptyPaywallProduct) -> Void)?
    var didStartRestore: (() -> Void)?
    var didFinishRestore: ((AdaptyProfile) -> Void)?
    var didFailRestore: ((AdaptyError) -> Void)?
    var didFailRendering: ((AdaptyError) -> Void)?
    var didFailLoadingProducts: ((AdaptyError) -> Bool)?

    // TODO: remove
    package init(
//        logId: String
    ) {
//        self.logId = logId
    }

    package init(
        logId: String,
        didPerformAction: @escaping (AdaptyUI.Action) -> Void,
        didSelectProduct: @escaping (AdaptyPaywallProduct) -> Void,
        didStartPurchase: @escaping (AdaptyPaywallProduct) -> Void,
        didFinishPurchase: @escaping (AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: @escaping (AdaptyPaywallProduct) -> Void,
        didStartRestore: @escaping () -> Void,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRendering: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: @escaping (AdaptyError) -> Bool
    ) {
//        self.logId = logId
        self.didPerformAction = didPerformAction
        self.didSelectProduct = didSelectProduct
        self.didStartPurchase = didStartPurchase
        self.didFinishPurchase = didFinishPurchase
        self.didFailPurchase = didFailPurchase
        self.didCancelPurchase = didCancelPurchase
        self.didStartRestore = didStartRestore
        self.didFinishRestore = didFinishRestore
        self.didFailRestore = didFailRestore
        self.didFailRendering = didFailRendering
        self.didFailLoadingProducts = didFailLoadingProducts
    }

    func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
    }

    func event_didPerformAction(_ action: AdaptyUI.Action) {
        log(.verbose, "event_didPerformAction: \(action)")
        didPerformAction?(action)
    }

    func event_didSelectProduct(_ product: AdaptyPaywallProduct) {
        log(.verbose, "event_didSelectProduct: \(product.vendorProductId)")
        didSelectProduct?(product)
    }

    func event_didStartPurchase(product: AdaptyPaywallProduct) {
        log(.verbose, "makePurchase begin")
        didStartPurchase?(product)
    }

    func event_didCancelPurchase(product: AdaptyPaywallProduct) {
        log(.verbose, "event_didCancelPurchase: \(product.vendorProductId)")
        didCancelPurchase?(product)
    }

    func event_didFinishPurchase(product: AdaptyPaywallProduct,
                                 purchasedInfo: AdaptyPurchasedInfo)
    {
        log(.verbose, "event_didFinishPurchase: \(product.vendorProductId)")
        didFinishPurchase?(product, purchasedInfo)
    }

    func event_didFailPurchase(product: AdaptyPaywallProduct,
                               error: AdaptyError)
    {
        log(.verbose, "event_didFailPurchase: \(product.vendorProductId), \(error)")
        didFailPurchase?(product, error)
    }

    func event_didStartRestore() {
        log(.verbose, "event_didStartRestore")
        didStartRestore?()
    }

    func event_didFinishRestore(with profile: AdaptyProfile) {
        log(.verbose, "event_didFinishRestore")
        didFinishRestore?(profile)
    }

    func event_didFailRestore(with error: AdaptyError) {
        log(.error, "event_didFailRestore: \(error)")
        didFailRestore?(error)
    }

    func event_didFailRendering(with error: AdaptyError) {
        log(.error, "event_didFailRendering: \(error)")
        didFailRendering?(error)
    }

    func event_didFailLoadingProducts(with error: AdaptyError) -> Bool {
        log(.error, "event_didFailLoadingProducts: \(error)")
        return didFailLoadingProducts?(error) ?? false
    }
}

#endif

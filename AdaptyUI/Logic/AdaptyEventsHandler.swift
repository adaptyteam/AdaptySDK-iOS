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
package class AdaptyEventsHandler {
    let logId: String = AdaptyUI.generateLogId()

    private let didPerformAction: ((AdaptyUI.Action) -> Void)?
    private let didSelectProduct: ((AdaptyPaywallProduct) -> Void)?
    private let didStartPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void)?
    private let didFailPurchase: ((AdaptyPaywallProduct, AdaptyError) -> Void)?
    private let didCancelPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didStartRestore: (() -> Void)?
    private let didFinishRestore: ((AdaptyProfile) -> Void)?
    private let didFailRestore: ((AdaptyError) -> Void)?
    private let didFailRendering: ((AdaptyError) -> Void)?
    private let didFailLoadingProducts: ((AdaptyError) -> Bool)?

    package init() {
        self.didPerformAction = nil
        self.didSelectProduct = nil
        self.didStartPurchase = nil
        self.didFinishPurchase = nil
        self.didFailPurchase = nil
        self.didCancelPurchase = nil
        self.didStartRestore = nil
        self.didFinishRestore = nil
        self.didFailRestore = nil
        self.didFailRendering = nil
        self.didFailLoadingProducts = nil
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

    func event_didFailRendering(with error: AdaptyUIError) {
        log(.error, "event_didFailRendering: \(error)")
        didFailRendering?(AdaptyError(error))
    }

    func event_didFailLoadingProducts(with error: AdaptyError) -> Bool {
        log(.error, "event_didFailLoadingProducts: \(error)")
        return didFailLoadingProducts?(error) ?? false
    }
}

#endif

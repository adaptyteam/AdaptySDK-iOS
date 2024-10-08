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
@MainActor // TODO: swift 6
package final class AdaptyEventsHandler {
    let logId: String = Log.stamp

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

    func event_didPerformAction(_ action: AdaptyUI.Action) {
        Log.ui.verbose("#\(logId)# event_didPerformAction: \(action)")
        didPerformAction?(action)
    }

    func event_didSelectProduct(_ underlying: AdaptyPaywallProduct) {
        Log.ui.verbose("#\(logId)# event_didSelectProduct: \(underlying.vendorProductId)")
        didSelectProduct?(underlying)
    }

    func event_didStartPurchase(underlying: AdaptyPaywallProduct) {
        Log.ui.verbose("#\(logId)# makePurchase begin")
        didStartPurchase?(underlying)
    }

    func event_didCancelPurchase(underlying: AdaptyPaywallProduct) {
        Log.ui.verbose("#\(logId)# event_didCancelPurchase: \(underlying.vendorProductId)")
        didCancelPurchase?(underlying)
    }

    func event_didFinishPurchase(
        underlying: AdaptyPaywallProduct,
        purchasedInfo: AdaptyPurchasedInfo
    ) {
        Log.ui.verbose("#\(logId)# event_didFinishPurchase: \(underlying.vendorProductId)")
        didFinishPurchase?(underlying, purchasedInfo)
    }

    func event_didFailPurchase(
        underlying: AdaptyPaywallProduct,
        error: AdaptyError
    ) {
        Log.ui.verbose("#\(logId)# event_didFailPurchase: \(underlying.vendorProductId), \(error)")
        didFailPurchase?(underlying, error)
    }

    func event_didStartRestore() {
        Log.ui.verbose("#\(logId)# event_didStartRestore")
        didStartRestore?()
    }

    func event_didFinishRestore(with profile: AdaptyProfile) {
        Log.ui.verbose("#\(logId)# event_didFinishRestore")
        didFinishRestore?(profile)
    }

    func event_didFailRestore(with error: AdaptyError) {
        Log.ui.error("#\(logId)# event_didFailRestore: \(error)")
        didFailRestore?(error)
    }

    func event_didFailRendering(with error: AdaptyUIError) {
        Log.ui.error("#\(logId)# event_didFailRendering: \(error)")
        didFailRendering?(AdaptyError(error))
    }

    func event_didFailLoadingProducts(with error: AdaptyError) -> Bool {
        Log.ui.error("#\(logId)# event_didFailLoadingProducts: \(error)")
        return didFailLoadingProducts?(error) ?? false
    }
}

#endif

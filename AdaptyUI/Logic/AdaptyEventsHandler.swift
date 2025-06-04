//
//  AdaptyEventsHandler.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptyEventsHandler: ObservableObject {
    enum PresentationState {
        case initial
        case appeared
        case disappeared
    }

    let logId: String

    var didAppear: (() -> Void)?
    var didDisappear: (() -> Void)?

    var didPerformAction: ((AdaptyUI.Action) -> Void)?
    var didSelectProduct: ((AdaptyPaywallProductWithoutDeterminingOffer) -> Void)?
    var didStartPurchase: ((AdaptyPaywallProduct) -> Void)?
    var didFinishPurchase: ((AdaptyPaywallProduct, AdaptyPurchaseResult) -> Void)?
    var didFailPurchase: ((AdaptyPaywallProduct, AdaptyError) -> Void)?
    var didFinishWebPaymentNavigation: ((AdaptyPaywallProduct?, AdaptyError?) -> Void)?
    var didStartRestore: (() -> Void)?
    var didFinishRestore: ((AdaptyProfile) -> Void)?
    var didFailRestore: ((AdaptyError) -> Void)?
    var didFailRendering: ((AdaptyUIError) -> Void)?
    var didFailLoadingProducts: ((AdaptyError) -> Bool)?
    var didPartiallyLoadProducts: (([String]) -> Void)?

    package init(logId: String) {
        self.logId = logId
        self.didPerformAction = nil
        self.didSelectProduct = nil
        self.didStartPurchase = nil
        self.didFinishPurchase = nil
        self.didFailPurchase = nil
        self.didFinishWebPaymentNavigation = nil
        self.didStartRestore = nil
        self.didFinishRestore = nil
        self.didFailRestore = nil
        self.didFailRendering = nil
        self.didFailLoadingProducts = nil
        self.didPartiallyLoadProducts = nil
    }

    @Published var presentationState: PresentationState = .initial

    func viewDidAppear() {
        Log.ui.verbose("#\(logId)# event_didAppear")

        presentationState = .appeared
        didAppear?()
    }

    func viewDidDisappear() {
        Log.ui.verbose("#\(logId)# event_didDisappear")

        presentationState = .disappeared
        didDisappear?()
    }

    func event_didPerformAction(_ action: AdaptyUI.Action) {
        Log.ui.verbose("#\(logId)# event_didPerformAction: \(action)")
        didPerformAction?(action)
    }

    func event_didSelectProduct(_ product: AdaptyPaywallProductWithoutDeterminingOffer) {
        Log.ui.verbose("#\(logId)# event_didSelectProduct: \(product.vendorProductId)")
        didSelectProduct?(product)
    }

    func event_didStartPurchase(product: AdaptyPaywallProduct) {
        Log.ui.verbose("#\(logId)# event_didStartPurchase")
        didStartPurchase?(product)
    }

    func event_didFinishPurchase(
        product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    ) {
        Log.ui.verbose("#\(logId)# event_didFinishPurchase: \(product.vendorProductId)")
        didFinishPurchase?(product, purchaseResult)
    }

    func event_didFinishWebPaymentNavigation(
        product: AdaptyPaywallProduct?,
        error: AdaptyError?
    ) {
        if let error {
            Log.ui.error("#\(logId)# event_didFinishWebPaymentNavigation: \(product?.vendorProductId ?? "null"), error: \(error)")
        } else {
            Log.ui.verbose("#\(logId)# event_didFinishWebPaymentNavigation: \(product?.vendorProductId ?? "null")")
        }
        didFinishWebPaymentNavigation?(product, error)
    }

    func event_didFailPurchase(
        product: AdaptyPaywallProduct,
        error: AdaptyError
    ) {
        Log.ui.verbose("#\(logId)# event_didFailPurchase: \(product.vendorProductId), \(error)")
        didFailPurchase?(product, error)
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
        didFailRendering?(error)
    }

    func event_didFailLoadingProducts(with error: AdaptyError) -> Bool {
        Log.ui.error("#\(logId)# event_didFailLoadingProducts: \(error)")
        return didFailLoadingProducts?(error) ?? false
    }

    func event_didPartiallyLoadProducts(failedProductIds: [String]) {
        Log.ui.error("#\(logId)# event_didPartiallyLoadProducts: \(failedProductIds)")
        didPartiallyLoadProducts?(failedProductIds)
    }
}

#endif

//
//  AdaptyPaywallView+ActionsHolder.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 20.09.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
final class AdaptyPaywallViewActionsHolder: ObservableObject {
    @Published var didPerformActionValue: AdaptyUI.Action?
    @Published var didSelectProductValue: AdaptyPaywallProduct?
    @Published var didStartPurchaseValue: AdaptyPaywallProduct?
    @Published var didFinishPurchaseValue: FinishPurchaseInfo?
    @Published var didFailPurchaseValue: FailPurchaseInfo?
    @Published var didCancelPurchaseValue: AdaptyPaywallProduct?
    @Published var didStartRestoreValue: Bool?
    @Published var didFinishRestoreValue: AdaptyProfile?
    @Published var didFailRestoreValue: AdaptyError?
    @Published var didFailRenderingValue: AdaptyError?
    @Published var didFailLoadingProductsValue: AdaptyError?

    func didPerformAction(_ value: AdaptyUI.Action) {
        didPerformActionValue = value
    }

    func didSelectProduct(_ value: AdaptyPaywallProduct) {
        didSelectProductValue = value
    }

    func didStartPurchase(_ value: AdaptyPaywallProduct) {
        didStartPurchaseValue = value
    }

    func didFinishPurchase(_ product: AdaptyPaywallProduct, _ info: AdaptyPurchasedInfo) {
        didFinishPurchaseValue = FinishPurchaseInfo(product: product, info: info)
    }

    func didFailPurchase(_ product: AdaptyPaywallProduct, _ error: AdaptyError) {
        didFailPurchaseValue = FailPurchaseInfo(product: product, error: error)
    }

    func didCancelPurchase(_ value: AdaptyPaywallProduct) {
        didCancelPurchaseValue = value
    }

    func didStartRestore() {
        didStartRestoreValue = true
    }

    func didFinishRestore(_ value: AdaptyProfile) {
        didFinishRestoreValue = value
    }

    func didFailRestore(_ value: AdaptyError) {
        didFailRestoreValue = value
    }

    func didFailRendering(_ value: AdaptyError) {
        didFailRenderingValue = value
    }

    func didFailLoadingProducts(_ value: AdaptyError) {
        didFailLoadingProductsValue = value
    }
}

#endif

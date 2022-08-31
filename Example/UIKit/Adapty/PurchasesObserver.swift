//
//  PurchasesObserver.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 16.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Combine
import Foundation

extension PaywallModel {
    var hasSKProducts: Bool {
        products.first?.skProduct != nil
    }
}

class PurchasesObserver: ObservableObject {
    static let shared = PurchasesObserver()
    static let paywallId = "example_ab_test"

    @Published var purchaserInfo: PurchaserInfoModel?
    @Published var paywall: PaywallModel?

    func loadInitialPaywallData() {
        Adapty.getPaywall(Self.paywallId) { [weak self] paywall, _ in
            self?.paywall = paywall

            // Since this version of PaywallModel object was obtained at the application start
            // it could be outdated (e.g. it could be loaded from the fallback_paywalls file)
            // We want to be sure in our PaywallModel is up to date

            self?.loadUpdatedPaywallData()
        }
    }

    @objc private func loadUpdatedPaywallData() {
        let paywallId = Self.paywallId

        Adapty.getPaywall(paywallId) { [weak self] paywall, _ in
            guard let paywall = paywall else { return }

            self?.paywall = paywall
        }
    }

    func makePurchase(_ product: ProductModel, completion: ((Error?) -> Void)?) {
        Adapty.makePurchase(product: product) { [weak self] purchaserInfo, _, _, _, error in
            if let error = error {
                completion?(error)
            } else {
                self?.purchaserInfo = purchaserInfo
                completion?(nil)
            }
        }
    }

    func restore(completion: ((Error?) -> Void)?) {
        Adapty.restorePurchases { [weak self] purchaserInfo, _, _, error in
            if let error = error {
                completion?(error)
            } else {
                self?.purchaserInfo = purchaserInfo
                completion?(nil)
            }
        }
    }
}

extension PurchasesObserver: AdaptyDelegate {
    func didReceiveUpdatedPurchaserInfo(_ purchaserInfo: PurchaserInfoModel) {
        self.purchaserInfo = purchaserInfo
    }

    func paymentQueue(shouldAddStorePaymentFor product: ProductModel, defermentCompletion makeDeferredPurchase: @escaping DeferredPurchaseCompletion) {
        // you can store makeDeferredPurchase callback and call it later as well

        // or you can call it right away in case you just want to continue purchase
        makeDeferredPurchase { _, _, _, _, _ in
            // check your purchase
        }
    }
}

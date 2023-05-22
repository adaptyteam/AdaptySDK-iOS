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

class PurchasesObserver: ObservableObject {
    static let shared = PurchasesObserver()

    @Published var profile: AdaptyProfile?
    @Published var products: [AdaptyPaywallProduct]?
    @Published var introEligibilities: [String: AdaptyEligibility]?

    @Published var paywall: AdaptyPaywall? {
        didSet {
            loadPaywallProducts()
        }
    }

    func loadInitialProfileData() {
        Adapty.getProfile { [weak self] result in
            self?.profile = try? result.get()
        }
    }

    func loadInitialPaywallData() {
        paywall = nil
        products = nil

        Adapty.getPaywall(AppConstants.examplePaywallId, locale: "fr") { [weak self] result in
            self?.paywall = try? result.get()
        }
    }

    private func loadPaywallProducts() {
        guard let paywall = paywall else { return }

        Adapty.getPaywallProducts(paywall: paywall) { [weak self] result in
            guard let products = try? result.get() else { return }

            self?.products = products
            self?.loadIntroductoryOfferEligibilities(products)
        }
    }

    private func loadIntroductoryOfferEligibilities(_ products: [AdaptyPaywallProduct]) {
        Adapty.getProductsIntroductoryOfferEligibility(products: products) { [weak self] result in
            self?.introEligibilities = try? result.get()
        }
    }

    func makePurchase(_ product: AdaptyPaywallProduct, completion: ((AdaptyError?) -> Void)?) {
        Adapty.makePurchase(product: product) { [weak self] result in
            switch result {
            case let .success(profile):
                self?.profile = profile
                completion?(nil)
            case let .failure(error):
                completion?(error)
            }
        }
    }

    func restore(completion: ((AdaptyError?) -> Void)?) {
        Adapty.restorePurchases { [weak self] result in
            switch result {
            case let .success(profile):
                self?.profile = profile
                completion?(nil)
            case let .failure(error):
                completion?(error)
            }
        }
    }
}

extension PurchasesObserver: AdaptyDelegate {
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        self.profile = profile
    }
}

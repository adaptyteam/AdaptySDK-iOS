//
//  AdaptyProductsViewModel.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, *)
protocol ProductsInfoProvider {
    func selectedProductInfo(by groupId: String) -> ProductInfoModel?
    func productInfo(by adaptyId: String) -> ProductInfoModel?
}

@available(iOS 15.0, *)
extension AdaptyProductsViewModel: ProductsInfoProvider {
    func selectedProductInfo(by groupId: String) -> ProductInfoModel? {
        guard let selectedProductId = selectedProductId(by: groupId) else { return nil }
        return productInfo(by: selectedProductId)
    }

    func productInfo(by adaptyId: String) -> ProductInfoModel? {
        let product = products.first(where: { $0.adaptyProductId == adaptyId })
        return product
    }
}

@available(iOS 15.0, *)
package class AdaptyProductsViewModel: ObservableObject {
    private let queue = DispatchQueue(label: "AdaptyUI.SDK.AdaptyProductsViewModel.Queue")

    private let eventsHandler: AdaptyEventsHandler

    let paywall: AdaptyPaywallInterface
    let viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    @Published var products: [ProductInfoModel]
    @Published var selectedProductsIds: [String: String]
    @Published var productsLoadingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    var adaptyProducts: [AdaptyPaywallProduct]? {
        didSet {
            products = Self.generateProductsInfos(
                paywall: paywall,
                products: adaptyProducts,
                eligibilities: introductoryOffersEligibilities
            )
        }
    }

    var introductoryOffersEligibilities: [String: AdaptyEligibility]? {
        didSet {
            products = Self.generateProductsInfos(
                paywall: paywall,
                products: adaptyProducts,
                eligibilities: introductoryOffersEligibilities
            )
        }
    }

    package init(
        eventsHandler: AdaptyEventsHandler,
        paywall: AdaptyPaywallInterface,
        products: [AdaptyPaywallProduct]?,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    ) {
        self.eventsHandler = eventsHandler
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration

        self.products = Self.generateProductsInfos(
            paywall: paywall,
            products: products,
            eligibilities: nil
        )

        selectedProductsIds = viewConfiguration.selectedProducts
    }

    private static func generateProductsInfos(
        paywall: AdaptyPaywallInterface,
        products: [AdaptyPaywallProduct]?,
        eligibilities: [String: AdaptyEligibility]?
    ) -> [ProductInfoModel] {
        guard let products else {
            return paywall.adaptyProductIds.map { EmptyProductInfo(adaptyProductId: $0) }
        }

        return products.map {
            RealProductInfo(
                product: $0,
                introEligibility: eligibilities?[$0.vendorProductId] ?? .ineligible
            )
        }
    }

    func loadProductsIfNeeded() {
        guard !productsLoadingInProgress else { return }

        guard adaptyProducts != nil, introductoryOffersEligibilities == nil else {
            loadProducts()
            return
        }

        loadProductsIntroductoryEligibilities()
    }

    func selectedProductId(by groupId: String) -> String? {
        selectedProductsIds[groupId]
    }

    func selectProduct(id: String, forGroupId groupId: String) {
        selectedProductsIds[groupId] = id

        if let selectedProduct = adaptyProducts?.first(where: { $0.adaptyProductId == id }) {
            eventsHandler.event_didSelectProduct(selectedProduct)
        }
    }

    private func loadProducts() {
        productsLoadingInProgress = true

        eventsHandler.log(.verbose, "loadProducts begin")

        queue.async { [weak self] in
            guard let self else { return }

            self.paywall.getPaywallProducts { [weak self] result in
                switch result {
                case let .success(products):
                    self?.eventsHandler.log(.verbose, "loadProducts success")

                    self?.adaptyProducts = products

                    // TODO: default selected products
//                    if self?.selectedProductId == nil {
//                        self?.selectedProductId = products.first?.vendorProductId
//                    }

                    self?.productsLoadingInProgress = false
                    self?.loadProductsIntroductoryEligibilities()
                case let .failure(error):
                    self?.eventsHandler.log(.error, "loadProducts fail: \(error)")
                    self?.productsLoadingInProgress = false

                    if self?.eventsHandler.event_didFailLoadingProducts(with: error) ?? false {
                        self?.queue.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                            self?.loadProducts()
                        }
                    }
                }
            }
        }
    }

    private func loadProductsIntroductoryEligibilities() {
        guard let products = adaptyProducts else { return }

        eventsHandler.log(.verbose, "loadProductsIntroductoryEligibilities begin")

        Adapty.getProductsIntroductoryOfferEligibility(products: products) { [weak self] result in
            switch result {
            case let .success(eligibilities):
                self?.introductoryOffersEligibilities = eligibilities
                self?.eventsHandler.log(.verbose, "loadProductsIntroductoryEligibilities success: \(eligibilities)")
            case let .failure(error):
                self?.eventsHandler.log(.error, "loadProductsIntroductoryEligibilities fail: \(error)")
            }
        }
    }

    private func handlePurchasedResult(
        product: AdaptyPaywallProduct,
        result: AdaptyResult<AdaptyPurchasedInfo>
    ) {
        switch result {
        case let .success(info):
            eventsHandler.event_didFinishPurchase(product: product, purchasedInfo: info)
        case let .failure(error):
            if error.adaptyErrorCode == .paymentCancelled {
                eventsHandler.event_didCancelPurchase(product: product)
            } else {
                eventsHandler.event_didFailPurchase(product: product, error: error)
            }
        }
    }

    private func handleRestoreResult(result: AdaptyResult<AdaptyProfile>) {
        switch result {
        case let .success(profile):
            eventsHandler.event_didFinishRestore(with: profile)
        case let .failure(error):
            eventsHandler.event_didFailRestore(with: error)
        }
    }

    func logShowPaywall() {
        eventsHandler.log(.verbose, "logShowPaywall begin")

        paywall.logShowPaywall(viewConfiguration: viewConfiguration) { [weak self] error in
            if let error {
                self?.eventsHandler.log(.error, "logShowPaywall fail: \(error)")
            } else {
                self?.eventsHandler.log(.verbose, "logShowPaywall success")
            }
        }
    }

    // MARK: Actions

    func purchaseSelectedProduct(fromGgoupId groupId: String) {
        guard let productId = selectedProductId(by: groupId) else { return }
        purchaseProduct(id: productId)
    }

    func purchaseProduct(id productId: String) {
        guard let product = adaptyProducts?.first(where: { $0.adaptyProductId == productId }) else { return }

        eventsHandler.event_didStartPurchase(product: product)
        purchaseInProgress = true

        Adapty.makePurchase(product: product) { [weak self] result in
            self?.handlePurchasedResult(product: product, result: result)
            self?.purchaseInProgress = false
        }
    }

    func restorePurchases() {
        eventsHandler.event_didStartRestore()

        restoreInProgress = true
        Adapty.restorePurchases { [weak self] result in
            self?.handleRestoreResult(result: result)
            self?.restoreInProgress = false
        }
    }
}

#endif

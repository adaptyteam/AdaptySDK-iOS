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
@MainActor
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
        let underlying = products.first(where: { $0.adaptyProductId == adaptyId })
        return underlying
    }
}

@available(iOS 15.0, *)
@MainActor
package final class AdaptyProductsViewModel: ObservableObject {
    private let queue = DispatchQueue(label: "AdaptyUI.SDK.AdaptyProductsViewModel.Queue")

    let logId: String
    private let eventsHandler: AdaptyEventsHandler
    private let paywallViewModel: AdaptyPaywallViewModel
    private let observerModeResolver: AdaptyObserverModeResolver?

    @Published var products: [ProductInfoModel]
    @Published var selectedProductsIds: [String: String]
    @Published var productsLoadingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    var adaptyProducts: [AdaptyPaywallProduct]? {
        didSet {
            products = Self.generateProductsInfos(
                paywall: paywallViewModel.paywall,
                products: adaptyProducts,
                eligibilities: introductoryOffersEligibilities
            )
        }
    }

    var introductoryOffersEligibilities: [String: AdaptyEligibility]? {
        didSet {
            products = Self.generateProductsInfos(
                paywall: paywallViewModel.paywall,
                products: adaptyProducts,
                eligibilities: introductoryOffersEligibilities
            )
        }
    }

    package init(
        eventsHandler: AdaptyEventsHandler,
        paywallViewModel: AdaptyPaywallViewModel,
        products: [AdaptyPaywallProduct]?,
        introductoryOffersEligibilities: [String: AdaptyEligibility]?,
        observerModeResolver: AdaptyObserverModeResolver?
    ) {
        logId = eventsHandler.logId
        self.eventsHandler = eventsHandler
        self.paywallViewModel = paywallViewModel

        self.introductoryOffersEligibilities = introductoryOffersEligibilities
        self.products = Self.generateProductsInfos(
            paywall: paywallViewModel.paywall,
            products: products,
            eligibilities: introductoryOffersEligibilities
        )

        selectedProductsIds = paywallViewModel.viewConfiguration.selectedProducts

        self.observerModeResolver = observerModeResolver
    }

    private static func generateProductsInfos(
        paywall _: AdaptyPaywallInterface,
        products: [AdaptyPaywallProduct]?,
        eligibilities: [String: AdaptyEligibility]?
    ) -> [ProductInfoModel] {
        guard let products else { return [] }

        return products.map {
            RealProductInfo(
                underlying: $0,
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

    func unselectProduct(forGroupId groupId: String) {
        selectedProductsIds.removeValue(forKey: groupId)
    }

    private func loadProducts() {
        productsLoadingInProgress = true
        let logId = logId
        Log.ui.verbose("#\(logId)# loadProducts begin")

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                let products = try await self.paywallViewModel.paywall.getPaywallProducts()
                Log.ui.verbose("#\(logId)# loadProducts success")

                self.adaptyProducts = products
                self.productsLoadingInProgress = false
                self.loadProductsIntroductoryEligibilities()
            } catch {
                Log.ui.error("#\(logId)# loadProducts fail: \(error)")
                self.productsLoadingInProgress = false

                if self.eventsHandler.event_didFailLoadingProducts(with: error.asAdaptyError) {
                    Task {
                        try await Task.sleep(seconds: 2)
                        self.loadProducts()
                    }
                }
            }
        }
    }

    private func loadProductsIntroductoryEligibilities() {
        guard let products = adaptyProducts else { return }

        let logId = logId
        Log.ui.verbose("#\(logId)# loadProductsIntroductoryEligibilities begin")

        Task { @MainActor [weak self] in
            do {
                let eligibilities = try await Adapty.getProductsIntroductoryOfferEligibility(products: products)
                self?.introductoryOffersEligibilities = eligibilities
                Log.ui.verbose("#\(logId)# loadProductsIntroductoryEligibilities success: \(eligibilities)")
            } catch {
                Log.ui.error("#\(logId)# loadProductsIntroductoryEligibilities fail: \(error)")
            }
        }
    }

    // MARK: Actions

    func purchaseSelectedProduct(fromGroupId groupId: String) {
        guard let productId = selectedProductId(by: groupId) else { return }
        purchaseProduct(id: productId)
    }

    func purchaseProduct(id productId: String) {
        guard let product = adaptyProducts?.first(where: { $0.adaptyProductId == productId }) else { return }
        let logId = logId
        if let observerModeResolver {
            observerModeResolver.observerMode(
                didInitiatePurchase: product,
                onStartPurchase: { [weak self] in
                    Log.ui.verbose("#\(logId)# observerDidStartPurchase")
                    self?.purchaseInProgress = true
                },
                onFinishPurchase: { [weak self] in
                    Log.ui.verbose("#\(logId)# observerDidFinishPurchase")
                    self?.purchaseInProgress = false
                }
            )
        } else {
            eventsHandler.event_didStartPurchase(product: product)
            purchaseInProgress = true

            Task { @MainActor [weak self] in
                do {
                    let purchasedInfo = try await Adapty.makePurchase(product: product)
                    self?.eventsHandler.event_didFinishPurchase(product: product, purchasedInfo: purchasedInfo)
                } catch {
                    let adaptyError = error.asAdaptyError

                    if adaptyError.adaptyErrorCode == .paymentCancelled {
                        self?.eventsHandler.event_didCancelPurchase(product: product)
                    } else {
                        self?.eventsHandler.event_didFailPurchase(product: product, error: adaptyError)
                    }
                }

                self?.purchaseInProgress = false
            }
        }
    }

    func restorePurchases() {
        eventsHandler.event_didStartRestore()

        restoreInProgress = true

        Task { @MainActor [weak self] in
            do {
                let profile = try await Adapty.restorePurchases()
                self?.eventsHandler.event_didFinishRestore(with: profile)
            } catch {
                self?.eventsHandler.event_didFailRestore(with: error.asAdaptyError)
            }

            self?.restoreInProgress = false
        }
    }
}

struct AdaptyUIUnknownError: CustomAdaptyError {
    let error: Error

    init(error: Error) {
        self.error = error
    }

    var originalError: Error? { error }
    let adaptyErrorCode = AdaptyError.ErrorCode.unknown

    var description: String { error.localizedDescription }
    var debugDescription: String { error.localizedDescription }
}

extension Error {
    var asAdaptyError: AdaptyError {
        if let adaptyError = self as? AdaptyError {
            return adaptyError
        } else if let customError = self as? CustomAdaptyError {
            return customError.asAdaptyError
        }

        return AdaptyError(AdaptyUIUnknownError(error: self))
    }
}

#endif

//
//  AdaptyProductsViewModel.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
protocol ProductsInfoProvider {
    func selectedProductInfo(by groupId: String) -> ProductInfoModel?
    func productInfo(by adaptyId: String) -> ProductInfoModel?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptyProductsViewModel: ObservableObject {
    private let queue = DispatchQueue(label: "AdaptyUI.SDK.AdaptyProductsViewModel.Queue")

    private var logId: String { eventsHandler.logId }
    private let eventsHandler: AdaptyEventsHandler
    private let paywallViewModel: AdaptyPaywallViewModel
    private let observerModeResolver: AdaptyObserverModeResolver?

    @Published private var paywallProductsWithoutOffer: [AdaptyPaywallProductWithoutDeterminingOffer]?
    @Published private var paywallProducts: [AdaptyPaywallProduct]?

    var products: [AdaptyPaywallProductWrapper] {
        return
            paywallProducts?.map { .full($0) } ??
            paywallProductsWithoutOffer?.map { .withoutOffer($0) } ??
            []
    }

    @Published var selectedProductsIds: [String: String]
    @Published var productsLoadingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    package init(
        eventsHandler: AdaptyEventsHandler,
        paywallViewModel: AdaptyPaywallViewModel,
        products: [AdaptyPaywallProduct]?,
        observerModeResolver: AdaptyObserverModeResolver?
    ) {
        self.eventsHandler = eventsHandler
        self.paywallViewModel = paywallViewModel

        paywallProducts = products
        selectedProductsIds = paywallViewModel.viewConfiguration.selectedProducts

        self.observerModeResolver = observerModeResolver
    }

    func resetSelectedProducts() {
        Log.ui.verbose("#\(logId)# resetSelectedProducts")
        selectedProductsIds = paywallViewModel.viewConfiguration.selectedProducts
    }

    func loadProductsIfNeeded() {
        guard !productsLoadingInProgress, paywallProducts == nil else { return }

        if paywallProductsWithoutOffer != nil {
            loadProducts()
        } else {
            loadProductsWithoutOffers()
        }
    }

    func selectedProductId(by groupId: String) -> String? {
        selectedProductsIds[groupId]
    }

    func selectProduct(id: String, forGroupId groupId: String) {
        selectedProductsIds[groupId] = id

        if let selectedProduct = products.first(where: { $0.adaptyProductId == id }) {
            eventsHandler.event_didSelectProduct(selectedProduct.anyProduct)
        }
    }

    func unselectProduct(forGroupId groupId: String) {
        selectedProductsIds.removeValue(forKey: groupId)
    }

    private func loadProductsWithoutOffers() {
        productsLoadingInProgress = true
        let logId = logId
        Log.ui.verbose("#\(logId)# loadProducts begin")

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                self.paywallProductsWithoutOffer = try await self.paywallViewModel.paywall.getPaywallProductsWithoutDeterminingOffer()
                self.loadProducts()
            } catch {
                Log.ui.error("#\(logId)# loadProducts fail: \(error)")
                self.productsLoadingInProgress = false

                if self.eventsHandler.event_didFailLoadingProducts(with: error.asAdaptyError) {
                    Task {
                        try await Task.sleep(seconds: 2)
                        self.loadProductsIfNeeded()
                    }
                }
            }
        }
    }

    private func loadProducts() {
        productsLoadingInProgress = true
        let logId = logId
        Log.ui.verbose("#\(logId)# loadProducts begin")

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                let paywallProducts: [AdaptyPaywallProduct]
                let productsResult = try await self.paywallViewModel.paywall.getPaywallProducts()

                switch productsResult {
                case .partial(let products, let failedIds):
                    Log.ui.warn("#\(logId)# loadProducts partial!")
                    paywallProducts = products
                    self.eventsHandler.event_didPartiallyLoadProducts(failedProductIds: failedIds)
                case .full(let products):
                    Log.ui.verbose("#\(logId)# loadProducts success")
                    paywallProducts = products
                }

                self.paywallProducts = paywallProducts
                self.productsLoadingInProgress = false
            } catch {
                Log.ui.error("#\(logId)# loadProducts fail: \(error)")
                self.productsLoadingInProgress = false

                if self.eventsHandler.event_didFailLoadingProducts(with: error.asAdaptyError) {
                    Task {
                        try await Task.sleep(seconds: 2)
                        self.loadProductsIfNeeded()
                    }
                }
            }
        }
    }

    // MARK: Actions

    func purchaseSelectedProduct(
        fromGroupId groupId: String,
        provider: AdaptyViewConfiguration.PaymentServiceProvider
    ) {
        guard let productId = selectedProductId(by: groupId) else { return }
        purchaseProduct(id: productId, provider: provider)
    }

    func purchaseProduct(id productId: String, provider: AdaptyViewConfiguration.PaymentServiceProvider) {
        guard let product = paywallProducts?.first(where: { $0.adaptyProductId == productId }) else {
            Log.ui.warn("#\(logId)# purchaseProduct unable to purchase \(productId)")
            return
        }

        switch provider {
        case .storeKit:
            purchaseProductWithStoreKit(product)
        case .openWebPaywall:
            purchaseProductInWeb(product)
        }
    }

    private func purchaseProductInWeb(_ product: AdaptyPaywallProduct) {
        Task { @MainActor [weak self] in
            do {
                try await Adapty.openWebPaywall(for: product)
                self?.eventsHandler
                    .event_didFinishWebPaymentNavigation(
                        product: product,
                        error: nil
                    )
            } catch {
                self?.eventsHandler
                    .event_didFinishWebPaymentNavigation(
                        product: product,
                        error: error.asAdaptyError
                    )
            }
        }
    }

    func openWebPaywall(_ product: AdaptyPaywallProduct) {
        guard let paywall = paywallViewModel.paywall as? AdaptyPaywall else { return }

        Task { @MainActor [weak self] in
            do {
                try await Adapty.openWebPaywall(for: paywall)
                self?.eventsHandler
                    .event_didFinishWebPaymentNavigation(
                        product: nil,
                        error: nil
                    )
            } catch {
                self?.eventsHandler
                    .event_didFinishWebPaymentNavigation(
                        product: nil,
                        error: error.asAdaptyError
                    )
            }
        }
    }

    private func purchaseProductWithStoreKit(_ product: AdaptyPaywallProduct) {
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
                    let purchaseResult = try await Adapty.makePurchase(product: product)
                    self?.eventsHandler.event_didFinishPurchase(
                        product: product,
                        purchaseResult: purchaseResult
                    )
                } catch {
                    let adaptyError = error.asAdaptyError

                    if adaptyError.adaptyErrorCode == .paymentCancelled {
                        self?.eventsHandler.event_didFinishPurchase(
                            product: product,
                            purchaseResult: .userCancelled
                        )
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

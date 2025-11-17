//
//  AdaptyUIProductsViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import Foundation

@MainActor
protocol ProductsInfoProvider {
    func selectedProductInfo(by groupId: String) -> ProductResolver?
    func productInfo(by productId: String) -> ProductResolver?
}

extension AdaptyUIProductsViewModel: ProductsInfoProvider {
    func selectedProductInfo(by groupId: String) -> ProductResolver? {
        guard let selectedProductId = selectedProductId(by: groupId) else { return nil }
        return productInfo(by: selectedProductId)
    }

    func productInfo(by productId: String) -> ProductResolver? {
        products.first(where: { $0.adaptyProductId == productId })
    }
}

@MainActor
package final class AdaptyUIProductsViewModel: ObservableObject {
    private let queue = DispatchQueue(label: "AdaptyUI.SDK.AdaptyUIProductsViewModel.Queue")

    private let logId: String
    private let logic: AdaptyUIBuilderLogic
    private let paywallViewModel: AdaptyUIPaywallViewModel
    private let presentationViewModel: AdaptyUIPresentationViewModel

    @Published private var paywallProductsWithoutOffer: [ProductResolver]?
    @Published private var paywallProducts: [ProductResolver]?

    var products: [ProductResolver] {
        return
            paywallProducts ?? paywallProductsWithoutOffer ?? []
    }

    @Published var selectedProductsIds: [String: String]
    @Published var productsLoadingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    package init(
        logId: String,
        logic: AdaptyUIBuilderLogic,
        presentationViewModel: AdaptyUIPresentationViewModel,
        paywallViewModel: AdaptyUIPaywallViewModel,
        products: [any ProductResolver]?
    ) {
        self.logId = logId
        self.logic = logic
        self.presentationViewModel = presentationViewModel
        self.paywallViewModel = paywallViewModel

        paywallProducts = products
        selectedProductsIds = paywallViewModel.viewConfiguration.selectedProducts
    }

    private var groupIdsForAutoNotification = Set<String>()
    
    package func resetSelectedProducts() {
        Log.ui.verbose("#\(logId)# resetSelectedProducts")

        groupIdsForAutoNotification.removeAll()
        selectedProductsIds = paywallViewModel.viewConfiguration.selectedProducts
    }

    package func loadProductsIfNeeded() {
        guard !productsLoadingInProgress, paywallProducts == nil else { return }
        loadProducts(determineOffers: paywallProductsWithoutOffer != nil)
    }

    func selectedProductId(by groupId: String) -> String? {
        guard let productId = selectedProductsIds[groupId] else {
            return nil
        }

        if !groupIdsForAutoNotification.contains(groupId),
           let selectedProduct = products.first(where: { $0.adaptyProductId == productId })
        {
            logic.reportDidSelectProduct(selectedProduct, automatic: true)
            groupIdsForAutoNotification.insert(groupId)
        }

        return productId
    }

    func selectProduct(id: String, forGroupId groupId: String) {
        selectedProductsIds[groupId] = id

        if let selectedProduct = products.first(where: { $0.adaptyProductId == id }) {
            logic.reportDidSelectProduct(selectedProduct, automatic: false)
        }
    }

    func unselectProduct(forGroupId groupId: String) {
        selectedProductsIds.removeValue(forKey: groupId)
    }

    private func loadProducts(determineOffers: Bool) {
        productsLoadingInProgress = true
        let logId = logId
        Log.ui.verbose("#\(logId)# loadProducts determineOffers: \(determineOffers) begin")

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                let productsResult = try await logic.getProducts(
                    determineOffers: determineOffers
                )
                if determineOffers {
                    self.paywallProducts = productsResult
                } else {
                    self.paywallProductsWithoutOffer = productsResult
                    self.loadProducts(determineOffers: true)
                }
            } catch {
                Log.ui.error("#\(logId)# loadProducts determineOffers: \(determineOffers) fail: \(error)")
                self.productsLoadingInProgress = false
                self.retryLoadingProductsIfNeeded(error: error)
            }
        }
    }

    private func retryLoadingProductsIfNeeded(error: Error) {
        guard logic.reportDidFailLoadingProductsShouldRetry(with: error) else { return }

        Task { [weak self] in
            guard let self else { return }

            try await Task.sleep(seconds: 2)

            if self.presentationViewModel.presentationState == .appeared {
                self.loadProductsIfNeeded()
            }
        }
    }

    // MARK: Actions

    func purchaseSelectedProduct(
        fromGroupId groupId: String,
        provider: VC.PaymentServiceProvider
    ) {
        guard let productId = selectedProductId(by: groupId) else { return }
        purchaseProduct(id: productId, provider: provider)
    }

    func purchaseProduct(id productId: String, provider: VC.PaymentServiceProvider) {
        guard let product = paywallProducts?.first(where: { $0.adaptyProductId == productId }) else {
            Log.ui.warn("#\(logId)# purchaseProduct unable to purchase \(productId)")
            return
        }

        switch provider {
        case .storeKit:
            logic.makePurchase(
                product: product,
                onStart: { [weak self] in self?.purchaseInProgress = true },
                onFinish: { [weak self] in self?.purchaseInProgress = false }
            )
        case .openWebPaywall:
            Task { @MainActor [weak self] in
                await self?.logic.openWebPaywall(for: product)
            }
        }
    }

    func restorePurchases() {
        Task { @MainActor [weak self] in
            self?.restoreInProgress = true
            await self?.logic.restorePurchases()
            self?.restoreInProgress = false
        }
    }
}

#endif

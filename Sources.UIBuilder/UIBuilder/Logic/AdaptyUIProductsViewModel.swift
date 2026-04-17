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

    func productInfo(by flowProductId: String) -> ProductResolver? {
        flowProducts?[flowProductId]
    }
}

@MainActor
package final class AdaptyUIProductsViewModel: ObservableObject {
    private let queue = DispatchQueue(label: "AdaptyUI.SDK.AdaptyUIProductsViewModel.Queue")

    private let logId: String
    private let logic: AdaptyUIBuilderLogic
    private let flowViewModel: AdaptyUIFlowViewModel
    private let presentationViewModel: AdaptyUIPresentationViewModel

    @Published fileprivate var flowProducts: [String: ProductResolver]?

    @Published var selectedProductsIds: [String: String]
    @Published var productsLoadingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    package init(
        logId: String,
        logic: AdaptyUIBuilderLogic,
        presentationViewModel: AdaptyUIPresentationViewModel,
        flowViewModel: AdaptyUIFlowViewModel,
        products: [any ProductResolver]?
    ) {
        self.logId = logId
        self.logic = logic
        self.presentationViewModel = presentationViewModel
        self.flowViewModel = flowViewModel

        if let products {
            flowProducts = Dictionary(uniqueKeysWithValues: products.map { ($0.flowId, $0) })
        }

        selectedProductsIds = [:] // TODO: use JS
    }

    private var groupIdsForAutoNotification = Set<String>()

    package func resetSelectedProducts() {
        Log.ui.verbose("#\(logId)# resetSelectedProducts")

        groupIdsForAutoNotification.removeAll()
        selectedProductsIds = [:] // TODO: use JS
    }

    package func loadProductsIfNeeded() {
        guard !productsLoadingInProgress, flowProducts == nil else { return }

        loadProducts()
    }

    func selectedProductId(by groupId: String) -> String? {
        guard let productId = selectedProductsIds[groupId] else {
            return nil
        }

        if !groupIdsForAutoNotification.contains(groupId),
           let selectedProduct = flowProducts?[productId]
        {
            logic.reportDidSelectProduct(selectedProduct, automatic: true)
            groupIdsForAutoNotification.insert(groupId)
        }

        return productId
    }

    func selectProduct(id: String, forGroupId groupId: String) {
        selectedProductsIds[groupId] = id

        if let selectedProduct = flowProducts?[id] {
            logic.reportDidSelectProduct(selectedProduct, automatic: false)
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
                let products = try await logic.getProducts()
                flowProducts = Dictionary(uniqueKeysWithValues: products.map { ($0.flowId, $0) })
            } catch {
                Log.ui.error("#\(logId)# loadProducts fail: \(error)")
                productsLoadingInProgress = false
                retryLoadingProductsIfNeeded(error: error)
            }
        }
    }

    private func retryLoadingProductsIfNeeded(error: Error) {
        guard logic.reportDidFailLoadingProductsShouldRetry(with: error) else { return }

        Task { [weak self] in
            guard let self else { return }

            try await Task.sleep(seconds: 2)

            if presentationViewModel.presentationState == .appeared {
                loadProductsIfNeeded()
            }
        }
    }

    // MARK: Actions

    func purchaseSelectedProduct(
        fromGroupId groupId: String,
        service: VC.Action.PaymentService
    ) {
        guard let productId = selectedProductId(by: groupId) else { return }
        purchaseProduct(id: productId, service: service)
    }

    func purchaseProduct(id flowProductId: String, service: VC.Action.PaymentService) {
        guard let product = flowProducts?[flowProductId] else {
            Log.ui.warn("#\(logId)# purchaseProduct unable to purchase \(flowProductId)")
            return
        }

        switch service {
        case .storeKit:
            logic.makePurchase(
                product: product,
                onStart: { [weak self] in self?.purchaseInProgress = true },
                onFinish: { [weak self] in self?.purchaseInProgress = false }
            )
        case .openWebPaywall(let openIn):
            Task { @MainActor [weak self] in
                await self?.logic.openWebPaywall(for: product, in: openIn)
            }
        }
    }

    func restorePurchases() {
        logic.restorePurchases(
            onStart: { [weak self] in self?.restoreInProgress = true },
            onFinish: { [weak self] in self?.restoreInProgress = false }
        )
    }
}

#endif

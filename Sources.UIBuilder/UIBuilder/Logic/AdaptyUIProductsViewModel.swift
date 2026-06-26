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
    func productInfo(by productId: String) -> ProductResolver?
}

extension AdaptyUIProductsViewModel: ProductsInfoProvider {
    package func productInfo(by flowProductId: String) -> ProductResolver? {
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

    @Published var productsLoadingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    package var onProductsLoaded: (([ProductResolver]) -> Void)?

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
    }
    
    package func loadProductsIfNeeded() {
        guard !productsLoadingInProgress, flowProducts == nil else { return }

        loadProducts()
    }

    package func prepareForReuse() {
        Log.ui.verbose("#\(logId)# prepareForReuse")
        productsLoadingInProgress = false
        purchaseInProgress = false
        restoreInProgress = false
    }

    func selectProduct(id: String) {
        if let selectedProduct = flowProducts?[id] {
            logic.reportDidSelectProduct(selectedProduct)
        }
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
                onProductsLoaded?(products)
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

    func purchaseProduct(
        id flowProductId: String,
        service: VC.Action.PaymentService,
        onFinish: @MainActor @Sendable @escaping (VS.PurchaseResult) -> Void
    ) {
        guard let product = flowProducts?[flowProductId] else {
            Log.ui.warn("#\(logId)# purchaseProduct unable to purchase \(flowProductId)")
            Task { @MainActor in onFinish(.fail) }
            return
        }

        let finish: @MainActor @Sendable (VS.PurchaseResult) -> Void = { [weak self] value in
            self?.purchaseInProgress = false
            onFinish(value)
        }

        switch service {
        case .storeKit:
            logic.makePurchase(
                product: product,
                onStart: { [weak self] in self?.purchaseInProgress = true },
                onFinish: finish
            )
        case .openWebPaywall(let openIn):
            Task { @MainActor [weak self] in
                await self?.logic.openWebPaywall(
                    for: product,
                    in: openIn,
                    onFinish: finish
                )
            }
        }
    }

    func restorePurchases(
        onFinish: @MainActor @Sendable @escaping (VS.RestorePurchasesResult) -> Void
    ) {
        logic.restorePurchases(
            onStart: { [weak self] in self?.restoreInProgress = true },
            onFinish: { [weak self] value in
                self?.restoreInProgress = false
                onFinish(value)
            }
        )
    }
}

#endif

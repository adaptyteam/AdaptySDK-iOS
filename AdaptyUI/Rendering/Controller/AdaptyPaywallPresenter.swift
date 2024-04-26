//
//  AdaptyPaywallPresenter.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

import Adapty
import Combine
import Foundation

protocol AdaptyPaywallPresenterDelegate: NSObject {
    func didFailLoadingProducts(with error: AdaptyError) -> Bool
}

class AdaptyPaywallPresenter {
    fileprivate let logId: String
    private let queue = DispatchQueue(label: "AdaptyUI.SDK.PaywallPresenterQueue")

    let paywall: AdaptyPaywall

    weak var delegate: AdaptyPaywallPresenterDelegate?

    @Published var viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    @Published var products: [ProductInfoModel]
    @Published var selectedProductId: String?
    @Published var productsFetchingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    var selectedAdaptyProduct: AdaptyPaywallProduct? {
        guard let selectedProductId = selectedProductId else { return nil }
        return adaptyProducts?.first(where: { $0.vendorProductId == selectedProductId })
    }

    var adaptyProducts: [AdaptyPaywallProduct]? {
        didSet {
            products = Self.generateProductsInfos(paywall: paywall,
                                                  products: adaptyProducts,
                                                  eligibilities: introductoryOffersEligibilities)
        }
    }

    var introductoryOffersEligibilities: [String: AdaptyEligibility]? {
        didSet {
            products = Self.generateProductsInfos(paywall: paywall,
                                                  products: adaptyProducts,
                                                  eligibilities: introductoryOffersEligibilities)
        }
    }

    private var cancellable = Set<AnyCancellable>()

    private(set) var initiatePurchaseOnTap: Bool

    var onPurchase: ((AdaptyResult<AdaptyPurchasedInfo>, AdaptyPaywallProduct) -> Void)?
    var onRestore: ((AdaptyResult<AdaptyProfile>) -> Void)?

    public init(
        logId: String,
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        selectedProductIndex: Int,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    ) {
        self.logId = logId
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration

        if let style = try? viewConfiguration.extractDefaultStyle() {
            initiatePurchaseOnTap = style.productBlock.initiatePurchaseOnTap
        } else {
            initiatePurchaseOnTap = false
        }

        self.products = Self.generateProductsInfos(paywall: paywall,
                                                   products: products,
                                                   eligibilities: nil)

        if selectedProductIndex < self.products.count && selectedProductIndex >= 0 {
            selectedProductId = self.products[selectedProductIndex].id
        }
    }

    private static func generateProductsInfos(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        eligibilities: [String: AdaptyEligibility]?
    ) -> [ProductInfoModel] {
        guard let products = products else {
            return paywall.vendorProductIds.map { EmptyProductInfo(id: $0) }
        }

        return products.map {
            RealProductInfo(product: $0,
                            introEligibility: eligibilities?[$0.vendorProductId] ?? .ineligible)
        }
    }

    func selectProduct(id: String) {
        log(.verbose, "select product: \(id)")
        selectedProductId = id
    }

    func logShowPaywall() {
        log(.verbose, "logShowPaywall begin")

        AdaptyUI.logShowPaywall(paywall,
                                viewConfiguration: viewConfiguration) { [weak self] error in
            if let error = error {
                self?.log(.error, "logShowPaywall fail: \(error)")
            } else {
                self?.log(.verbose, "logShowPaywall success")
            }
        }
    }

    func makePurchase() {
        guard let selectedProduct = selectedAdaptyProduct else { return }

        log(.verbose, "makePurchase begin")

        purchaseInProgress = true
        Adapty.makePurchase(product: selectedProduct) { [weak self] result in
            self?.onPurchase?(result, selectedProduct)
            self?.purchaseInProgress = false

            switch result {
            case .success:
                self?.log(.verbose, "makePurchase success")
            case let .failure(error):
                self?.log(.error, "makePurchase fail: \(error)")
            }
        }
    }

    func restorePurchases() {
        log(.verbose, "restorePurchases begin")

        restoreInProgress = true
        Adapty.restorePurchases { [weak self] result in
            self?.onRestore?(result)
            self?.restoreInProgress = false

            switch result {
            case .success:
                self?.log(.verbose, "restorePurchases success")
            case let .failure(error):
                self?.log(.error, "restorePurchases fail: \(error)")
            }
        }
    }

    // MARK: - Products Fetching

    func loadProductsIfNeeded() {
        guard !productsLoadingInProgress else { return }

        guard adaptyProducts != nil, introductoryOffersEligibilities == nil else {
            loadProducts()
            return
        }

        loadProductsIntroductoryEligibilities()
    }

    private var productsLoadingInProgress = false

    private func loadProducts() {
        productsLoadingInProgress = true

        log(.verbose, "loadProducts begin")

        queue.async { [weak self] in
            guard let self = self else { return }

            Adapty.getPaywallProducts(paywall: self.paywall) { [weak self] result in
                switch result {
                case let .success(products):
                    self?.log(.verbose, "loadProducts success")

                    self?.adaptyProducts = products

                    if self?.selectedProductId == nil {
                        self?.selectedProductId = products.first?.vendorProductId
                    }

                    self?.productsLoadingInProgress = false
                    self?.loadProductsIntroductoryEligibilities()
                case let .failure(error):
                    self?.log(.error, "loadProducts fail: \(error)")
                    self?.productsLoadingInProgress = false

                    if self?.delegate?.didFailLoadingProducts(with: error) ?? false {
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

        log(.verbose, "loadProductsIntroductoryEligibilities begin")

        Adapty.getProductsIntroductoryOfferEligibility(products: products) { [weak self] result in
            switch result {
            case let .success(eligibilities):
                self?.introductoryOffersEligibilities = eligibilities
                self?.log(.verbose, "loadProductsIntroductoryEligibilities success: \(eligibilities)")
            case let .failure(error):
                self?.log(.error, "loadProductsIntroductoryEligibilities fail: \(error)")
            }
        }
    }
}

extension AdaptyPaywallPresenter {
    func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
    }
}

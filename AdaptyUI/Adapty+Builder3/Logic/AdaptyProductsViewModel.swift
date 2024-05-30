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
    var selectedProductInfo: ProductInfoModel? { get }

    func productInfo(by adaptyId: String) -> ProductInfoModel?
}

@available(iOS 15.0, *)
extension AdaptyProductsViewModel: ProductsInfoProvider {
    var selectedProductInfo: ProductInfoModel? {
        guard let selectedProductId else { return nil }
        return productInfo(by: selectedProductId)
    }

    func productInfo(by adaptyId: String) -> ProductInfoModel? {
        products.first(where: { $0.adaptyProduct?.adaptyProductId == adaptyId })
    }
}

@available(iOS 15.0, *)
class AdaptyProductsViewModel: ObservableObject {
    private let queue = DispatchQueue(label: "AdaptyUI.SDK.AdaptyProductsViewModel.Queue")

    private let logId: String
    private let paywall: AdaptyPaywall?
    private let viewConfiguration: AdaptyUI.LocalizedViewConfiguration?

    var onFailLoadingProducts: ((AdaptyError) -> Bool)?

    @Published var products: [ProductInfoModel]
    @Published var selectedProductId: String?
    @Published var productsLoadingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    var adaptyProducts: [AdaptyPaywallProduct]? {
        didSet {
            guard let paywall else { return }
            products = Self.generateProductsInfos(paywall: paywall,
                                                  products: adaptyProducts,
                                                  eligibilities: introductoryOffersEligibilities)
        }
    }

    var introductoryOffersEligibilities: [String: AdaptyEligibility]? {
        didSet {
            guard let paywall else { return }
            products = Self.generateProductsInfos(paywall: paywall,
                                                  products: adaptyProducts,
                                                  eligibilities: introductoryOffersEligibilities)
        }
    }

    #if DEBUG
    init(logId: String) {
        self.logId = logId
        products = ["test_product_1", "test_product_2"].map { EmptyProductInfo(id: $0) }

        paywall = nil
        viewConfiguration = nil
    }
    #endif

    init(
        logId: String,
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    ) {
        self.logId = logId
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration

        self.products = Self.generateProductsInfos(paywall: paywall,
                                                   products: products,
                                                   eligibilities: nil)
    }

    private func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
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

    func loadProductsIfNeeded() {
        guard !productsLoadingInProgress else { return }

        guard adaptyProducts != nil, introductoryOffersEligibilities == nil else {
            loadProducts()
            return
        }

        loadProductsIntroductoryEligibilities()
    }

    func selectProduct(id: String) {
        selectedProductId = id
    }

    private func loadProducts() {
        guard let paywall else { return }

        productsLoadingInProgress = true

        log(.verbose, "loadProducts begin")

        queue.async { [weak self] in
            guard let self = self else { return }

            Adapty.getPaywallProducts(paywall: paywall) { [weak self] result in
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

                    if self?.onFailLoadingProducts?(error) ?? false {
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

#endif

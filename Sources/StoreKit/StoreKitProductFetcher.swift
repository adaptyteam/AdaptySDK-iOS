//
//  StoreKitProductFetcher.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import StoreKit

private let log = Log.productManager

actor StoreKitProductFetcher {
    func fetchProducts(ids productIds: Set<String>, retryCount: Int = 3) async throws(AdaptyError) -> [StoreKit.Product] {
        log.verbose("Called fetch StoreKit.Products: \(productIds) retryCount:\(retryCount)")

        let stamp = Log.stamp
        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
            methodName: .fetchProducts,
            stamp: stamp,
            params: [
                "products_ids": productIds,
            ]
        ))

        let products: [StoreKit.Product]
        do {
            products = try await StoreKit.Product.products(for: productIds)
        } catch {
            log.error("Can't fetch Storekit.Products from Store \(error)")

            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .fetchProducts,
                stamp: stamp,
                error: "\(error.localizedDescription). Detail: \(error)"
            ))

            throw StoreKitManagerError.requestProductsFailed(error).asAdaptyError
        }

        if products.isEmpty {
            log.verbose("fetch StoreKit.Products result is empty")
        }

        for product in products {
            log.verbose("Found StoreKit.Product \(product.id) \(product.displayName) \(product.displayPrice)")
        }

        Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
            methodName: .fetchProducts,
            stamp: stamp,
            params: [
                "products_ids": products.map(\.id),
            ]
        ))

        return products
    }
}

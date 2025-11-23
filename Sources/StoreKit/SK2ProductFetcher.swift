//
//  SK2ProductFetcher.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import StoreKit

private let log = Log.productManager

actor SK2ProductFetcher {
    func fetchProducts(ids productIds: Set<String>, retryCount: Int = 3) async throws(AdaptyError) -> [StoreKit.Product] {
        log.verbose("Called fetch SK2Products: \(productIds) retryCount:\(retryCount)")

        let stamp = Log.stamp
        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
            methodName: .fetchSK2Products,
            stamp: stamp,
            params: [
                "products_ids": productIds,
            ]
        ))

        let sk2Products: [StoreKit.Product]
        do {
            sk2Products = try await StoreKit.Product.products(for: productIds)
        } catch {
            log.error("Can't fetch SK2Products from Store \(error)")

            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .fetchSK2Products,
                stamp: stamp,
                error: "\(error.localizedDescription). Detail: \(error)"
            ))

            throw StoreKitManagerError.requestSK2ProductsFailed(error).asAdaptyError
        }

        if sk2Products.isEmpty {
            log.verbose("fetch SK2Products result is empty")
        }

        for sk2Product in sk2Products {
            log.verbose("Found StoreKit.Product \(sk2Product.id) \(sk2Product.displayName) \(sk2Product.displayPrice)")
        }

        Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
            methodName: .fetchSK2Products,
            stamp: stamp,
            params: [
                "products_ids": sk2Products.map { $0.id },
            ]
        ))

        return sk2Products
    }
}

//
//  SK2ProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.04.2023
//

import StoreKit

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
actor SK2ProductsFetcher {
    private var products = [String: Product]()

    func fetchProducts(productIdentifiers productIds: Set<String>, fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount: Int = 3) async throws -> [Product] {
        guard !productIds.isEmpty else {
            throw SKManagerError.noProductIDsFound().asAdaptyError
        }

        if fetchPolicy == .returnCacheDataElseLoad {
            let products = productIds.compactMap { self.products[$0] }
            if products.count == productIds.count {
                return products
            }
        }

        Log.verbose("SK2ProductsFetcher: Called StoreKit.Product.products productIds:\(productIds)")

        let callId = Log.stamp
        let methodName = "fetch_sk2_products"
        Adapty.logSystemEvent(AdaptyAppleRequestParameters(
            methodName: methodName,
            callId: callId,
            params: [
                "products_ids": .value(productIds),
            ]))

        let products: [Product]
        do {
            products = try await StoreKit.Product.products(for: productIds)
        } catch {
            Log.error("SK2ProductsFetcher: Can't fetch products from Store \(error)")

            Adapty.logSystemEvent(AdaptyAppleResponseParameters(
                methodName: methodName,
                callId: callId,
                error: "\(error.localizedDescription). Detail: \(error)"
            ))

            throw SKManagerError.requestSK2ProductsFailed(error).asAdaptyError
        }

        if products.isEmpty {
            Log.verbose("SK2ProductsFetcher: fetch result is empty")
        }

        for product in products {
            Log.verbose("SK2ProductsFetcher: found product \(product.id) \(product.displayName) \(product.displayPrice)")
        }

        Adapty.logSystemEvent(AdaptyAppleResponseParameters(
            methodName: methodName,
            callId: callId,
            params: [
                "products_ids": .value(products.map { $0.id }),
            ]))

        guard !products.isEmpty else {
            throw SKManagerError.noProductIDsFound().asAdaptyError
        }

        products.forEach { self.products[$0.id] = $0 }

        return products
    }
}

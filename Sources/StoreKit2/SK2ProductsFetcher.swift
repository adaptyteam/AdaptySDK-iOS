//
//  SK2ProductsFetcher.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.04.2023
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
actor SK2ProductsFetcher {
    private var sk2Products = [String: SK2Product]()

    func fetchProducts(productIdentifiers productIds: Set<String>, fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount _: Int = 3) async throws -> [SK2Product] {
        guard !productIds.isEmpty else {
            throw SKManagerError.noProductIDsFound().asAdaptyError
        }

        if fetchPolicy == .returnCacheDataElseLoad {
            let products = productIds.compactMap { self.sk2Products[$0] }
            if products.count == productIds.count {
                return products
            }
        }

        Log.verbose("SK2ProductsFetcher: Called SK2Product.products productIds:\(productIds)")

        let callId = Log.stamp
        let methodName = "fetch_sk2_products"
        Adapty.logSystemEvent(AdaptyAppleRequestParameters(
            methodName: methodName,
            callId: callId,
            params: [
                "products_ids": .value(productIds),
            ]
        ))

        let sk2Products: [SK2Product]
        do {
            sk2Products = try await SK2Product.products(for: productIds)
        } catch {
            Log.error("SK2ProductsFetcher: Can't fetch products from Store \(error)")

            Adapty.logSystemEvent(AdaptyAppleResponseParameters(
                methodName: methodName,
                callId: callId,
                error: "\(error.localizedDescription). Detail: \(error)"
            ))

            throw SKManagerError.requestSK2ProductsFailed(error).asAdaptyError
        }

        if sk2Products.isEmpty {
            Log.verbose("SK2ProductsFetcher: fetch result is empty")
        }

        for sk2Product in sk2Products {
            Log.verbose("SK2ProductsFetcher: found product \(sk2Product.id) \(sk2Product.displayName) \(sk2Product.displayPrice)")
        }

        Adapty.logSystemEvent(AdaptyAppleResponseParameters(
            methodName: methodName,
            callId: callId,
            params: [
                "products_ids": .value(sk2Products.map { $0.id }),
            ]
        ))

        guard !sk2Products.isEmpty else {
            throw SKManagerError.noProductIDsFound().asAdaptyError
        }

        sk2Products.forEach { self.sk2Products[$0.id] = $0 }

        return sk2Products
    }
}

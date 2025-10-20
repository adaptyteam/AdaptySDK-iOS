//
//  StoreKitProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.10.2024
//

import StoreKit

protocol StoreKitProductsManager: Actor, Sendable {
    func storeProductInfo(productInfo: [BackendProductInfo]) async
    func fetchProduct(id productId: String, fetchPolicy: ProductsFetchPolicy) async throws(AdaptyError) -> AdaptyProduct?
}

extension SK1ProductsManager: StoreKitProductsManager {
    func fetchProduct(id productId: String, fetchPolicy: ProductsFetchPolicy) async throws(AdaptyError) -> AdaptyProduct? {
        try await fetchSK1Product(id: productId, fetchPolicy: fetchPolicy).asAdaptyProduct
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2ProductsManager: StoreKitProductsManager {
    func fetchProduct(id productId: String, fetchPolicy: ProductsFetchPolicy) async throws(AdaptyError) -> AdaptyProduct? {
        try await fetchSK2Product(id: productId, fetchPolicy: fetchPolicy).asAdaptyProduct
    }
}

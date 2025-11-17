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

extension SK2ProductsManager: StoreKitProductsManager {
    func fetchProduct(id productId: String, fetchPolicy: ProductsFetchPolicy) async throws(AdaptyError) -> AdaptyProduct? {
        try await fetchSK2Product(id: productId, fetchPolicy: fetchPolicy).asAdaptyProduct
    }
}

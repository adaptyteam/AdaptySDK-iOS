//
//  SK2ProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import Foundation
import StoreKit

private let log = Log.productManager

actor SK2ProductsManager {
    private let apiKeyPrefix: String
    private let storage: BackendProductInfoStorage
    private let session: Backend.MainExecutor

    private var products = [String: StoreKit.Product]()
    private let sk2ProductsFetcher = SK2ProductFetcher()

    init(apiKeyPrefix: String, session: Backend.MainExecutor, storage: BackendProductInfoStorage) {
        self.apiKeyPrefix = apiKeyPrefix
        self.session = session
        self.storage = storage
        Task {
            try? await prefetchAllProducts(maxRetries: Int.max)
        }
    }

    private var fetchingAllProducts = false

    func storeProductInfo(productInfo: [BackendProductInfo]) async {
        await storage.set(productInfo: productInfo)
    }

    func getProductInfo(vendorId: String) async -> BackendProductInfo? {
        await storage.productInfo(by: vendorId)
    }

    private func prefetchAllProducts(maxRetries: Int) async throws(AdaptyError) {
        guard !fetchingAllProducts else { return }
        defer { fetchingAllProducts = false }
        fetchingAllProducts = true

        do throws(HTTPError) {
            let response = try await self.session.fetchProductInfo(apiKeyPrefix: apiKeyPrefix, maxRetries: maxRetries)
            await storage.set(allProductInfo: response)
            let allProductVendorIds = await Set(storage.allProductVendorIds ?? [])
            _ = try? await fetchSK2Products(ids: allProductVendorIds)
        } catch {
            throw error.asAdaptyError
        }
    }
}

extension SK2ProductsManager {
    func fetchSK2ProductsInSameOrder(ids productIds: [String], fetchPolicy: ProductsFetchPolicy = .default) async throws(AdaptyError) -> [StoreKit.Product] {
        let products = try await fetchSK2Products(ids: Set(productIds), fetchPolicy: fetchPolicy)

        return productIds.compactMap { id in
            products.first { $0.id == id }
        }
    }

    func fetchSK2Product(id productId: String, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3) async throws(AdaptyError) -> StoreKit.Product {
        do throws(AdaptyError) {
            let products = try await fetchSK2Products(ids: Set([productId]), fetchPolicy: fetchPolicy, retryCount: retryCount)

            guard let product = products.first else {
                throw StoreKitManagerError.noProductIDsFound().asAdaptyError
            }

            return product
        } catch {
            log.error("fetch StoreKit.Product \(productId) error: \(error)")
            throw error
        }
    }

    func fetchSK2Products(ids productIds: Set<String>, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3)
    async throws(AdaptyError) -> [StoreKit.Product]
    {
        guard productIds.isNotEmpty else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        if fetchPolicy == .returnCacheDataElseLoad {
            let products = productIds.compactMap { self.products[$0] }
            if products.count == productIds.count {
                return products
            }
        }

        let products = try await sk2ProductsFetcher.fetchProducts(ids: productIds, retryCount: retryCount)

        guard products.isNotEmpty else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        products.forEach { self.products[$0.id] = $0 }

        return products
    }
}

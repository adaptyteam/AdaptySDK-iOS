//
//  SK1ProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import Foundation

private let log = Log.Category(name: "SK1ProductsManager")

actor SK1ProductsManager: StoreKitProductsManager {
    private let apiKeyPrefix: String
    private var cache: ProductVendorIdsCache
    private let session: Backend.MainExecutor

    private var products = [String: SK1Product]()

    init(apiKeyPrefix: String, storage: ProductVendorIdsStorage, session: Backend.MainExecutor) {
        self.apiKeyPrefix = apiKeyPrefix
        self.session = session
        cache = ProductVendorIdsCache(storage: storage)
    }

    private var fetchingAllProducts = false

    private func finishFetchingAllProducts() {
        fetchingAllProducts = false
    }

    private func fetchAllProducts() async {
        guard !fetchingAllProducts else { return }
        fetchingAllProducts = true

        do {
            let response = try await session.fetchAllProductVendorIds(apiKeyPrefix: apiKeyPrefix)
            cache.setProductVendorIds(response)
        } catch {
            guard !error.isCancelled else { return }
            Task.detached(priority: .utility) { [weak self] in
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000 /* second */ )
                await self?.finishFetchingAllProducts()
                await self?.fetchAllProducts()
            }
            return
        }

        let allProductVendorIds = Set(cache.allProductVendorIds ?? [])

        Task.detached(priority: .high) { [weak self] in
            _ = try? await self?.fetchSK1Products(ids: allProductVendorIds)
            await self?.finishFetchingAllProducts()
        }
    }
}

private extension Error {
    var isCancelled: Bool {
        let error = unwrapped
        if let httpError = error as? HTTPError { return httpError.isCancelled }
        return false
    }
}

extension SK1ProductsManager {
    func fetchSK1Product(id productId: String, fetchPolicy _: ProductsFetchPolicy = .default, retryCount _: Int = 3) async throws -> SK1Product {
        do {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        } catch {
            log.error("fetch SK1Product \(productId) error: \(error)")
            throw error
        }
    }

    func fetchSK1ProductsInSameOrder(ids productIds: [String], fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3) async throws -> [SK1Product] {
        let products = try await fetchSK1Products(ids: Set(productIds), fetchPolicy: fetchPolicy, retryCount: retryCount)

        return productIds.compactMap { id in
            products.first { $0.productIdentifier == id }
        }
    }

    func fetchSK1Products(ids productIds: Set<String>, fetchPolicy: ProductsFetchPolicy = .default, retryCount _: Int = 3)
        async throws -> [SK1Product] {
        guard !productIds.isEmpty else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        guard !productIds.isEmpty else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        if fetchPolicy == .returnCacheDataElseLoad {
            let products = productIds.compactMap { self.products[$0] }
            if products.count == productIds.count {
                return products
            }
        }

        let products = [SK1Product]() // TODO: need fetcher

        guard !products.isEmpty else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        products.forEach { self.products[$0.productIdentifier] = $0 }

        return products
    }
}
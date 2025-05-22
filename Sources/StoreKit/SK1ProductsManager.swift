//
//  SK1ProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import Foundation

private let log = Log.sk1ProductManager

actor SK1ProductsManager: StoreKitProductsManager {
    private let apiKeyPrefix: String
    private let storage: ProductVendorIdsStorage
    private let session: Backend.MainExecutor

    private var products = [String: SK1Product]()
    private let sk1ProductsFetcher = SK1ProductFetcher()

    init(apiKeyPrefix: String, session: Backend.MainExecutor, storage: ProductVendorIdsStorage) {
        self.apiKeyPrefix = apiKeyPrefix
        self.session = session
        self.storage = storage
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
            await storage.set(productVendorIds: response)
        } catch {
            guard !error.isCancelled else { return }
            Task.detached(priority: .utility) { [weak self] in
                try? await Task.sleep(duration: .seconds(2))
                await self?.finishFetchingAllProducts()
                await self?.fetchAllProducts() // TODO: recursion ???
            }
            return
        }

        let allProductVendorIds = await Set(storage.allProductVendorIds ?? [])

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
    func fetchSK1ProductsInSameOrder(ids productIds: [String], fetchPolicy: ProductsFetchPolicy = .default) async throws -> [SK1Product] {
        let products = try await fetchSK1Products(ids: Set(productIds), fetchPolicy: fetchPolicy)

        return productIds.compactMap { id in
            products.first { $0.productIdentifier == id }
        }
    }

    func fetchSK1Product(id productId: String, fetchPolicy: ProductsFetchPolicy = .default) async throws -> SK1Product {
        do {
            let products = try await fetchSK1Products(ids: Set([productId]), fetchPolicy: fetchPolicy)

            guard let product = products.first else {
                throw StoreKitManagerError.noProductIDsFound().asAdaptyError
            }

            return product
        } catch {
            log.error("fetch SK1Product \(productId) error: \(error)")
            throw error
        }
    }

    func fetchSK1Products(ids productIds: Set<String>, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3)
        async throws -> [SK1Product]
    {
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

        let products = try await sk1ProductsFetcher.fetchProducts(ids: productIds, retryCount: retryCount)

        guard !products.isEmpty else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        products.forEach { self.products[$0.productIdentifier] = $0 }

        return products
    }
}

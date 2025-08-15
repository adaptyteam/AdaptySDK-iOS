//
//  SK2ProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import Foundation

private let log = Log.sk2ProductManager

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
actor SK2ProductsManager {
    private let apiKeyPrefix: String
    private let storage: BackendProductInfoStorage
    private let session: Backend.MainExecutor

    private var products = [String: SK2Product]()
    private let sk2ProductsFetcher = SK2ProductFetcher()

    init(apiKeyPrefix: String, session: Backend.MainExecutor, storage: BackendProductInfoStorage) {
        self.apiKeyPrefix = apiKeyPrefix
        self.session = session
        self.storage = storage
        Task {
            await fetchAllProducts()
        }
    }

    private var fetchingAllProducts = false

    private func finishFetchingAllProducts() {
        fetchingAllProducts = false
    }

    func storeProductInfo(productInfo: [BackendProductInfo]) async {
        await storage.set(productInfo: productInfo)
    }
    
    private func fetchAllProducts() async {
        guard !fetchingAllProducts else { return }
        fetchingAllProducts = true

        do {
            let response = try await session.fetchProductInfo(apiKeyPrefix: apiKeyPrefix)
            await storage.set(allProductInfo: response)
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
            _ = try? await self?.fetchSK2Products(ids: allProductVendorIds)
            await self?.finishFetchingAllProducts()
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2ProductsManager {
    func fetchSK2ProductsInSameOrder(ids productIds: [String], fetchPolicy: ProductsFetchPolicy = .default) async throws(AdaptyError) -> [SK2Product] {
        let products = try await fetchSK2Products(ids: Set(productIds), fetchPolicy: fetchPolicy)

        return productIds.compactMap { id in
            products.first { $0.id == id }
        }
    }

    func fetchSK2Product(id productId: String, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3) async throws(AdaptyError) -> SK2Product {
        do throws(AdaptyError) {
            let products = try await fetchSK2Products(ids: Set([productId]), fetchPolicy: fetchPolicy, retryCount: retryCount)

            guard let product = products.first else {
                throw StoreKitManagerError.noProductIDsFound().asAdaptyError
            }

            return product
        } catch {
            log.error("fetch SK2Product \(productId) error: \(error)")
            throw error
        }
    }

    func fetchSK2Products(ids productIds: Set<String>, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3)
        async throws(AdaptyError) -> [SK2Product]
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

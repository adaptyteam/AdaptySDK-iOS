//
//  SK2ProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import Foundation

private let log = Log.Category(name: "SK2ProductsManager")

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
actor SK2ProductsManager {
    private let apiKeyPrefix: String
    private var cache: ProductVendorIdsCache
    private let session: Backend.MainExecutor
    private var products = [String: SK2Product]()
    private let sk2ProductsFetcher = SK2ProductFetcher()

    init(apiKeyPrefix: String, storage: ProductVendorIdsStorage, backend: Backend) {
        self.apiKeyPrefix = apiKeyPrefix
        cache = ProductVendorIdsCache(storage: storage)
        session = backend.createMainExecutor()
        Task {
            await fetchAllProducts()
        }
    }

    var fetchingAllProducts = false

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
            _ = try? await self?.fetchSK2Products(ids: allProductVendorIds)
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

enum ProductsFetchPolicy: Sendable, Hashable {
    case `default`
    case returnCacheDataElseLoad
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2ProductsManager {
    func fetchSK2Product(id productId: String, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3) async throws -> SK2Product {
        let products = try await fetchSK2Products(ids: Set([productId]), fetchPolicy: fetchPolicy, retryCount: retryCount)

        guard let product = products.first else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        return product
    }

    func fetchSK2ProductsInSameOrder(ids productIds: [String], fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3) async throws -> [SK2Product] {
        let products = try await fetchSK2Products(ids: Set(productIds), fetchPolicy: fetchPolicy, retryCount: retryCount)

        return productIds.compactMap { id in
            products.first { $0.id == id }
        }
    }

    func fetchSK2Products(ids productIds: Set<String>, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3)
        async throws -> [SK2Product] {
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

        let products = try await sk2ProductsFetcher.fetchProducts(ids: productIds, retryCount: retryCount)

        guard !products.isEmpty else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        products.forEach { self.products[$0.id] = $0 }

        return products
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2ProductsManager {
    func getSK2IntroductoryOfferEligibility(
        productIds: [String]
    ) async throws -> [String: AdaptyEligibility] {
        do {
            let products = try await fetchSK2Products(ids: Set(productIds), fetchPolicy: .returnCacheDataElseLoad)

            var result = [String: AdaptyEligibility]()

            for product in products {
                result[product.id] = await product.introductoryOfferEligibility
            }

            return result
        } catch {
            throw error.asAdaptyError ?? StoreKitManagerError.requestSK2ProductsFailed(error).asAdaptyError
        }
    }
}

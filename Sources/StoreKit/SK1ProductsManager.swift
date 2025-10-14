//
//  SK1ProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import Foundation

private let log = Log.sk1ProductManager

actor SK1ProductsManager {
    private let apiKeyPrefix: String
    private let storage: BackendProductInfoStorage
    private let session: Backend.MainExecutor

    private var products = [String: SK1Product]()
    private let sk1ProductsFetcher = SK1ProductFetcher()

    init(apiKeyPrefix: String, session: Backend.MainExecutor, storage: BackendProductInfoStorage) {
        self.apiKeyPrefix = apiKeyPrefix
        self.session = session
        self.storage = storage
    }

    private var fetchingAllProducts = false

    func storeProductInfo(productInfo: [BackendProductInfo]) async {
        await storage.set(productInfo: productInfo)
    }

    private func fetchAllProducts() async {
        guard !fetchingAllProducts else { return }
        defer { fetchingAllProducts = false }
        fetchingAllProducts = true

        while !Task.isCancelled {
            do throws(HTTPError) {
                let response = try await self.session.fetchProductInfo(apiKeyPrefix: apiKeyPrefix)
                await storage.set(allProductInfo: response)
                let allProductVendorIds = await Set(storage.allProductVendorIds ?? [])
                _ = try? await fetchSK1Products(ids: allProductVendorIds)
            } catch {
                guard !error.isCancelled else { return }
                try? await Task.sleep(duration: .seconds(2))
            }
        }
    }
}

extension SK1ProductsManager {
    func fetchSK1ProductsInSameOrder(ids productIds: [String], fetchPolicy: ProductsFetchPolicy = .default) async throws(AdaptyError) -> [SK1Product] {
        let products = try await fetchSK1Products(ids: Set(productIds), fetchPolicy: fetchPolicy)

        return productIds.compactMap { id in
            products.first { $0.productIdentifier == id }
        }
    }

    func fetchSK1Product(id productId: String, fetchPolicy: ProductsFetchPolicy = .default) async throws(AdaptyError) -> SK1Product {
        do throws(AdaptyError) {
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
        async throws(AdaptyError) -> [SK1Product]
    {
        guard productIds.isNotEmpty else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        guard productIds.isNotEmpty else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        if fetchPolicy == .returnCacheDataElseLoad {
            let products = productIds.compactMap { self.products[$0] }
            if products.count == productIds.count {
                return products
            }
        }

        let products = try await sk1ProductsFetcher.fetchProducts(ids: productIds, retryCount: retryCount)

        guard products.isNotEmpty else {
            throw StoreKitManagerError.noProductIDsFound().asAdaptyError
        }

        products.forEach { self.products[$0.productIdentifier] = $0 }

        return products
    }
}

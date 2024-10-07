//
//  SK1ProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

private let log = Log.Category(name: "SKProductsManager")

final class SK1ProductsManager {
    private let queue = DispatchQueue(label: "Adapty.SDK.SKProductsManager")
    private let apiKeyPrefix: String
    private var cache: ProductVendorIdsCache
    private let session: HTTPSession
    private var sending: Bool = false
    private let storeKit1Fetcher: SK1ProductsFetcher

    init(apiKeyPrefix: String, storage: ProductVendorIdsStorage, backend: Backend) {
        self.apiKeyPrefix = apiKeyPrefix
        cache = ProductVendorIdsCache(storage: storage)
        session = backend.createHTTPSession(responseQueue: queue)
        storeKit1Fetcher = SK1ProductsFetcher(queue: queue)

        fetchAllProducts()
    }

    func fetchSK1Product(productIdentifier productId: String, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<SK1Product>) {
        fetchSK1Products(productIdentifiers: Set([productId]), fetchPolicy: fetchPolicy, retryCount: retryCount) { result in
            completion(result.flatMap {
                guard let product = $0.first else {
                    return .failure(SKManagerError.noProductIDsFound().asAdaptyError)
                }
                return .success(product)
            })
        }
    }

    func fetchSK1ProductsInSameOrder(productIdentifiers productIds: [String], fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[SK1Product]>) {
        fetchSK1Products(productIdentifiers: Set(productIds), fetchPolicy: fetchPolicy, retryCount: retryCount) {
            completion($0.map { skProducts in
                productIds.compactMap { id in
                    skProducts.first { $0.productIdentifier == id }
                }
            })
        }
    }

    func fetchSK1Products(productIdentifiers productIds: Set<String>, fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[SK1Product]>) {
        storeKit1Fetcher.fetchProducts(productIdentifiers: productIds, fetchPolicy: fetchPolicy, retryCount: retryCount, completion)
    }

    private func fetchAllProducts() {
        queue.async { [weak self] in
            guard let self, !self.sending else { return }
            self.sending = true
            let request = FetchAllProductVendorIdsRequest(apiKeyPrefix: self.apiKeyPrefix)
            self.session.perform(request, logName: "get_products_ids") { [weak self] (result: FetchAllProductVendorIdsRequest.Result) in
                defer { self?.sending = false }
                guard let self else { return }
                switch result {
                case let .success(response):
                    self.cache.setProductVendorIds(response.body.value)
                    let allProductVendorIds = Set(self.cache.allProductVendorIds ?? [])
                    self.fetchSK1Products(productIdentifiers: allProductVendorIds) { _ in }
                    if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                        self.fetchSK2Products(productIdentifiers: allProductVendorIds) { _ in }
                    }
                case let .failure(error):
                    guard !error.isCancelled else { return }
                    self.queue.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                        self?.fetchAllProducts()
                    }
                }
            }
        }
    }
}



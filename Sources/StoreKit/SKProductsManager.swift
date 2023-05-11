//
//  SKProductsManager.swift
//  Adapty
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

final class SKProductsManager {
    private let queue = DispatchQueue(label: "Adapty.SDK.SKProductsManager")
    private var cache: ProductVendorIdsCache
    private let session: HTTPSession
    private var sending: Bool = false
    private let storeKit1Fetcher: SK1ProductsFetcher
    private let _storeKit2Fetcher: Any?

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    private var storeKit2Fetcher: SK2ProductsFetcher? {
        _storeKit2Fetcher! as? SK2ProductsFetcher
    }

    init(storage: ProductVendorIdsStorage, backend: Backend) {
        cache = ProductVendorIdsCache(storage: storage)
        session = backend.createHTTPSession(responseQueue: queue)
        storeKit1Fetcher = SK1ProductsFetcher(queue: queue)
        if #available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *), Adapty.Configuration.enabledStoreKit2ProductsFetcher {
            _storeKit2Fetcher = SK2ProductsFetcher()
        } else {
            _storeKit2Fetcher = nil
        }
        fetchAllProducts()
    }

    enum ProductsFetchPolicy {
        case `default`
        case returnCacheDataElseLoad
    }

    func fetchSK1Product(productIdentifier productId: String, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<SKProduct?>) {
        fetchSK1Products(productIdentifiers: [productId], fetchPolicy: fetchPolicy, retryCount: retryCount) { result in
            completion(result.map { $0.first })
        }
    }

    func fetchSK1Products(productIdentifiers productIds: Set<String>, fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[SKProduct]>) {
        storeKit1Fetcher.fetchProducts(productIdentifiers: productIds, fetchPolicy: fetchPolicy, retryCount: retryCount, completion)
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    func fetchSK2Product(productIdentifier productId: String, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<Product?>) {
        fetchSK2Products(productIdentifiers: [productId], fetchPolicy: fetchPolicy, retryCount: retryCount) { result in
            completion(result.map { $0.first })
        }
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    func fetchSK2Products(productIdentifiers productIds: Set<String>, fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[Product]>) {
        guard let storeKit2Fetcher = storeKit2Fetcher else {
            completion(.success([]))
            return
        }
        Task {
            do {
                completion(.success(
                    try await storeKit2Fetcher.fetchProducts(productIdentifiers: productIds, fetchPolicy: fetchPolicy, retryCount: retryCount)
                ))
            } catch {
                completion(.failure(
                    (error as? AdaptyError) ?? (error as? CustomAdaptyError)?.asAdaptyError ?? SKManagerError.requestSK2ProductsFailed(error).asAdaptyError
                ))
            }
        }
    }

    private func fetchAllProducts() {
        queue.async { [weak self] in
            guard let self = self, !self.sending else { return }
            self.sending = true
            let profileId = self.cache.profileId
            let request = FetchAllProductVendorIdsRequest(profileId: profileId, responseHash: self.cache.allProductVendorIds?.hash)
            self.session.perform(request, logName: "get_products_ids") { [weak self] (result: FetchAllProductVendorIdsRequest.Result) in
                defer { self?.sending = false }
                guard let self = self else { return }
                switch result {
                case let .success(response):
                    if let value = response.body.value {
                        self.cache.setProductVendorIds(VH(value, hash: response.headers.getBackendResponseHash()))
                    }
                    self.fetchSK1Products(productIdentifiers: self.cache.allProductVendorIdsWithFallback) { _ in }
                    if #available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *) {
                        self.fetchSK2Products(productIdentifiers: self.cache.allProductVendorIdsWithFallback) { _ in }
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

extension SKProductsManager {
    func getPaywallProducts(paywall: AdaptyPaywall, _ backendProducts: [BackendProduct], _ completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProduct]>) {
        fetchSK1Products(productIdentifiers: Set(backendProducts.map { $0.vendorId })) {
            completion($0.map { (skProducts: [SKProduct]) -> [AdaptyPaywallProduct] in
                backendProducts.compactMap { product in
                    guard let sk = skProducts.first(where: { $0.productIdentifier == product.vendorId }) else {
                        return nil
                    }
                    return AdaptyPaywallProduct(paywall: paywall, product: product, skProduct: sk)
                }
            })
        }
    }
}

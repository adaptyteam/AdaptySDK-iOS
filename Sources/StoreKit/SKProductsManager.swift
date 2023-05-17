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
        guard let fetcher = _storeKit2Fetcher else { return nil }
        return fetcher as? SK2ProductsFetcher
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
    func getSKProductsWithIntroductoryOfferEligibility(vendorProductIds: [String], _ completion: @escaping AdaptyResultCompletion<[(SKProduct, AdaptyEligibility)]>) {
        getSK1ProductsWithIntroductoryOfferEligibility(vendorProductIds: vendorProductIds) { [weak self] result in

            let skProducts: [(SKProduct, AdaptyEligibility)]
            switch result {
            case let .failure(error):
                completion(.failure(error))
                return
            case let .success(value):
                skProducts = value
            }

            let unknownProductIds = skProducts.compactMap {
                $0.1 == .unknown ? $0.0.productIdentifier : nil
            }

            guard !unknownProductIds.isEmpty,
                  Adapty.Configuration.enabledStoreKit2ProductsFetcher,
                  let self = self,
                  #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
            else {
                completion(.success(skProducts))
                return
            }

            self.getSK2ProductsWithIntroductoryOfferEligibility(vendorProductIds: unknownProductIds) { result in

                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    return
                case let .success(value):
                    completion(.success(skProducts.apply(Dictionary(uniqueKeysWithValues: value.map { ($0.id, $1) }))))
                }
            }
        }
    }

    func getSK1ProductsWithIntroductoryOfferEligibility(vendorProductIds: [String], _ completion: @escaping AdaptyResultCompletion<[(SKProduct, AdaptyEligibility)]>) {
        fetchSK1Products(productIdentifiers: Set(vendorProductIds), fetchPolicy: .returnCacheDataElseLoad) { result in
            completion(result.map { value in
                value.map { ($0, $0.introductoryOfferEligibility) }
            })
        }
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    func getSK2ProductsWithIntroductoryOfferEligibility(vendorProductIds: [String], _ completion: @escaping AdaptyResultCompletion<[(Product, AdaptyEligibility)]>) {
        guard let storeKit2Fetcher = storeKit2Fetcher else {
            completion(.success([]))
            return
        }
        Task {
            do {
                var result = [(Product, AdaptyEligibility)]()
                for product in try await storeKit2Fetcher.fetchProducts(productIdentifiers: Set(vendorProductIds), fetchPolicy: .returnCacheDataElseLoad) {
                    result.append((product, await product.introductoryOfferEligibility))
                }
                completion(.success(result))
            } catch {
                completion(.failure(
                    (error as? AdaptyError) ?? (error as? CustomAdaptyError)?.asAdaptyError ?? SKManagerError.requestSK2ProductsFailed(error).asAdaptyError
                ))
            }
        }
    }
}

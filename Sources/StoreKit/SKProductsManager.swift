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
        if #available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *),
           Environment.StoreKit2.available {
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

    func fetchSK1Product(productIdentifier productId: String, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<SKProduct>) {
        fetchSK1Products(productIdentifiers: Set([productId]), fetchPolicy: fetchPolicy, retryCount: retryCount) { result in
            completion(result.flatMap {
                guard let product = $0.first else {
                    return .failure(SKManagerError.noProductIDsFound().asAdaptyError)
                }
                return .success(product)
            })
        }
    }

    func fetchSK1ProductsInSameOrder(productIdentifiers productIds: [String], fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[SKProduct]>) {
        fetchSK1Products(productIdentifiers: Set(productIds), fetchPolicy: fetchPolicy, retryCount: retryCount) {
            completion($0.map { skProducts in
                productIds.compactMap { id in
                    skProducts.first { $0.productIdentifier == id }
                }
            })
        }
    }

    func fetchSK1Products(productIdentifiers productIds: Set<String>, fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[SKProduct]>) {
        storeKit1Fetcher.fetchProducts(productIdentifiers: productIds, fetchPolicy: fetchPolicy, retryCount: retryCount, completion)
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    func fetchSK2Product(productIdentifier productId: String, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<Product>) {
        fetchSK2Products(productIdentifiers: Set([productId]), fetchPolicy: fetchPolicy, retryCount: retryCount) { result in
            completion(result.flatMap {
                guard let product = $0.first else {
                    return .failure(SKManagerError.noProductIDsFound().asAdaptyError)
                }
                return .success(product)
            })
        }
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    func fetchSK2ProductsInSameOrder(productIdentifiers productIds: [String], fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[Product]>) {
        fetchSK2Products(productIdentifiers: Set(productIds), fetchPolicy: fetchPolicy, retryCount: retryCount) {
            completion($0.map { products in
                productIds.compactMap { id in
                    products.first { $0.id == id }
                }
            })
        }
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    func fetchSK2Products(productIdentifiers productIds: Set<String>, fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[Product]>) {
        guard let storeKit2Fetcher = storeKit2Fetcher else {
            Log.error("SKProductsManager: SK2ProductsFetcher is not initialized!")
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
    func getIntroductoryOfferEligibility(vendorProductIds: Set<String>, _ completion: @escaping AdaptyResultCompletion<[String: AdaptyEligibility?]>) {
        fetchSK1Products(productIdentifiers: vendorProductIds, fetchPolicy: .returnCacheDataElseLoad) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
                return
            case let .success(value):
                self?.getIntroductoryOfferEligibility(sk1Products: value, completion)
            }
        }
    }

    func getIntroductoryOfferEligibility(sk1Products: [SKProduct], _ completion: @escaping AdaptyResultCompletion<[String: AdaptyEligibility?]>) {
        let introductoryOfferEligibilityByVendorProductId = [String: AdaptyEligibility?](sk1Products.map { ($0.productIdentifier, $0.introductoryOfferEligibility) }, uniquingKeysWith: { $1 })

        let vendorProductIdsWithUnknownEligibility = introductoryOfferEligibilityByVendorProductId.filter { $0.value == nil }.map { $0.key }

        guard !vendorProductIdsWithUnknownEligibility.isEmpty,
              Adapty.Configuration.enabledStoreKit2IntroEligibilityCheck,
              #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
        else {
            completion(.success(introductoryOfferEligibilityByVendorProductId))
            return
        }

        getSK2IntroductoryOfferEligibility(vendorProductIds: vendorProductIdsWithUnknownEligibility) { result in
            completion(result.map {
                introductoryOfferEligibilityByVendorProductId.merging($0, uniquingKeysWith: { $1 })
            })
        }
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    func getSK2IntroductoryOfferEligibility(vendorProductIds: [String], _ completion: @escaping AdaptyResultCompletion<[String: AdaptyEligibility]>) {
        guard let storeKit2Fetcher = storeKit2Fetcher else {
            Log.error("SKProductsManager: SK2ProductsFetcher is not initialized!")
            completion(.success([:]))
            return
        }
        Task {
            do {
                var result = [String: AdaptyEligibility]()
                for product in try await storeKit2Fetcher.fetchProducts(productIdentifiers: Set(vendorProductIds), fetchPolicy: .returnCacheDataElseLoad) {
                    result[product.id] = await product.introductoryOfferEligibility
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

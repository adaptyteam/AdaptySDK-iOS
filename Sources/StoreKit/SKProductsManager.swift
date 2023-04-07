//
//  SKProductsManager.swift
//  Adapty
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

final class SKProductsManager: NSObject {
    private let queue = DispatchQueue(label: "Adapty.SDK.SKProductsManager")
    private var invalidProductIdentifiers = Set<String>()
    private var products = [String: SKProduct]()
    private var requests = [SKRequest: (productIds: Set<String>, retryCount: Int)]()
    private var completionHandlers = [Set<String>: [AdaptyResultCompletion<[SKProduct]>]]()
    private var cache: ProductVendorIdsCache
    private let session: HTTPSession
    private var sending: Bool = false

    init(storage: ProductVendorIdsStorage, backend: Backend) {
        cache = ProductVendorIdsCache(storage: storage)
        session = backend.createHTTPSession(responseQueue: queue)
        super.init()
        fetchAllProducts()
    }

    enum ProductsFetchPolicy {
        case `default`
        case returnCacheDataElseLoad
    }

    func fetchProduct(productIdentifier productId: String, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<SKProduct?>) {
        fetchProducts(productIdentifiers: [productId]) { result in
            completion(result.map { $0.first })
        }
    }

    func fetchProducts(productIdentifiers productIds: Set<String>, fetchPolicy: ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[SKProduct]>) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

            if fetchPolicy == .returnCacheDataElseLoad {
                let products = productIds.compactMap { self.products[$0] }
                if products.count == productIds.count {
                    completion(.success(products))
                    return
                }
            }

            let productIds = productIds.subtracting(self.invalidProductIdentifiers)
            guard !productIds.isEmpty else {
                completion(.failure(SKManagerError.noProductIDsFound().asAdaptyError))
                return
            }

            if let handlers = self.completionHandlers[productIds] {
                self.completionHandlers[productIds] = handlers + [completion]
                return
            }
            self.completionHandlers[productIds] = [completion]
            self.startRequest(productIds, retryCount: retryCount)
        }
    }

    private func startRequest(_ productIds: Set<String>, retryCount: Int) {
        Log.verbose("SKProductManager: Called SKProductsManager.startRequest productIds:\(productIds) retryCount:\(retryCount)")
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        requests[request] = (productIds: productIds, retryCount: retryCount)
        request.start()
        Adapty.logSystemEvent(AdaptyAppleRequestParameters(methodName: "fetch_products", callId: "SKR\(request.hash)", params: ["products_ids": .value(productIds)]))
    }

    fileprivate func saveProducts(_ products: [SKProduct]) {
        queue.async { [weak self] in
            guard let self = self else { return }
            products.forEach { self.products[$0.productIdentifier] = $0 }
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
                    self.fetchProducts(productIdentifiers: self.cache.allProductVendorIdsWithFallback) { _ in }
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

extension SKProductsManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        queue.async { [weak self] in
            Adapty.logSystemEvent(AdaptyAppleResponseParameters(
                methodName: "fetch_products",
                callId: "SKR\(request.hash)",
                params: [
                    "products_count": .value(response.products.count),
                    "invalid_products": .valueOrNil(response.invalidProductIdentifiers),
                ]))

            if response.products.isEmpty {
                Log.verbose("SKProductManager: SKProductsResponse don't have any product")
            }

            for product in response.products {
                Log.verbose("SKProductManager: found product \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
            }

            guard let self = self else { return }
            if !response.invalidProductIdentifiers.isEmpty {
                Log.warn("SKProductManager: InvalidProductIdentifiers: \(response.invalidProductIdentifiers.joined(separator: ", "))")
                self.invalidProductIdentifiers.formUnion(response.invalidProductIdentifiers)
            }

            guard let productIds = self.requests[request]?.productIds else {
                Log.error("SKProductManager: Not found SKRequest in self.requests")
                return
            }

            self.requests.removeValue(forKey: request)

            guard let handlers = self.completionHandlers.removeValue(forKey: productIds) else {
                Log.error("SKProductManager: Not found completionHandlers by productIds")
                return
            }

            guard !response.products.isEmpty else {
                let error = SKManagerError.noProductIDsFound().asAdaptyError
                for completion in handlers {
                    completion(.failure(error))
                }
                return
            }

            self.saveProducts(response.products)
            for completion in handlers {
                completion(.success(response.products))
            }
        }
    }

    func requestDidFinish(_ request: SKRequest) {
        Adapty.logSystemEvent(AdaptyAppleEventQueueHandlerParameters(eventName: "fetch_products_did_finish", callId: "SKR\(request.hash)"
        ))
        request.cancel()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        defer { request.cancel() }
        queue.async { [weak self] in
            Adapty.logSystemEvent(AdaptyAppleResponseParameters(methodName: "fetch_products",
                                                                callId: "SKR\(request.hash)",
                                                                error: "\(error.localizedDescription). Detail: \(error)"))

            Log.error("SKProductManager: Can't fetch products from Store \(error)")
            guard let self = self else { return }
            guard let (productIds, retryCount) = self.requests[request] else {
                Log.error("SKProductManager: Not found SKRequest in self.requests")
                return
            }

            guard retryCount <= 0 else {
                self.queue.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                    self?.startRequest(productIds, retryCount: retryCount - 1)
                }
                return
            }

            self.requests.removeValue(forKey: request)

            guard let handlers = self.completionHandlers.removeValue(forKey: productIds) else {
                Log.error("SKProductManager: Not found completionHandlers by productIds")
                return
            }

            let error = SKManagerError.requestSKProductsFailed(error).asAdaptyError
            for completion in handlers {
                completion(.failure(error))
            }
        }
    }
}

extension SKProductsManager {
    func getPaywallProducts(paywall: AdaptyPaywall, _ backendProducts: [BackendProduct], _ completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProduct]>) {
        fetchProducts(productIdentifiers: Set(backendProducts.map { $0.vendorId })) {
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

//
//  SK1ProductsFetcher.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 27.04.2023
//

import StoreKit

private let log = Log.Category(name: "SK1ProductsFetcher")

final class SK1ProductsFetcher: NSObject {
    private let queue: DispatchQueue
    private var sk1Products = [String: SK1Product]()
    private var requests = [SKRequest: (productIds: Set<String>, retryCount: Int)]()
    private var completionHandlers = [Set<String>: [AdaptyResultCompletion<[SK1Product]>]]()

    init(queue: DispatchQueue) {
        self.queue = queue
        super.init()
    }

    func fetchProducts(productIdentifiers productIds: Set<String>, fetchPolicy: SKProductsManager.ProductsFetchPolicy = .default, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[SK1Product]>) {
        queue.async { [weak self] in
            guard let self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

            guard !productIds.isEmpty else {
                completion(.failure(SKManagerError.noProductIDsFound().asAdaptyError))
                return
            }

            if fetchPolicy == .returnCacheDataElseLoad {
                let products = productIds.compactMap { self.sk1Products[$0] }
                if products.count == productIds.count {
                    completion(.success(products))
                    return
                }
            }

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
        log.verbose("Called startRequest productIds:\(productIds) retryCount:\(retryCount)")
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        requests[request] = (productIds: productIds, retryCount: retryCount)
        request.start()
        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: "fetch_sk1_products", stamp: "SKR\(request.hash)", params: ["products_ids": productIds]))
    }

    fileprivate func saveProducts(_ sk1Products: [SK1Product]) {
        queue.async { [weak self] in
            guard let self else { return }
            sk1Products.forEach { self.sk1Products[$0.productIdentifier] = $0 }
        }
    }
}

extension SK1ProductsFetcher: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        queue.async { [weak self] in
            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: "fetch_products",
                stamp: "SKR\(request.hash)",
                params: [
                    "products_ids": response.products.map { $0.productIdentifier },
                    "invalid_products": response.invalidProductIdentifiers,
                ]
            ))

            if response.products.isEmpty {
                log.verbose("SKProductsResponse don't have any product")
            }

            for product in response.products {
                log.verbose("found product \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
            }

            guard let self else { return }
            if !response.invalidProductIdentifiers.isEmpty {
                log.warn("InvalidProductIdentifiers: \(response.invalidProductIdentifiers.joined(separator: ", "))")
            }

            guard let productIds = self.requests[request]?.productIds else {
                log.error("Not found SKRequest in self.requests")
                return
            }

            self.requests.removeValue(forKey: request)

            guard let handlers = self.completionHandlers.removeValue(forKey: productIds) else {
                log.error("Not found completionHandlers by productIds")
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
        Adapty.trackSystemEvent(AdaptyAppleEventQueueHandlerParameters(
            eventName: "fetch_products_did_finish",
            stamp: "SKR\(request.hash)"
        ))
        request.cancel()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        defer { request.cancel() }
        queue.async { [weak self] in
            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: "fetch_products",
                stamp: "SKR\(request.hash)",
                error: "\(error.localizedDescription). Detail: \(error)"
            ))

            log.error("Can't fetch products from Store \(error)")
            guard let self else { return }
            guard let (productIds, retryCount) = self.requests[request] else {
                log.error("Not found SKRequest in self.requests")
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
                log.error("Not found completionHandlers by productIds")
                return
            }

            let error = SKManagerError.requestSK1ProductsFailed(error).asAdaptyError
            for completion in handlers {
                completion(.failure(error))
            }
        }
    }
}

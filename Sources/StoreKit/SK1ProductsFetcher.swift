//
//  SK1ProductsFetcher.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 27.04.2023
//

import StoreKit

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
        Log.verbose("SK1ProductsFetcher: Called startRequest productIds:\(productIds) retryCount:\(retryCount)")
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        requests[request] = (productIds: productIds, retryCount: retryCount)
        request.start()
        Adapty.logSystemEvent(AdaptyAppleRequestParameters(methodName: "fetch_sk1_products", callId: "SKR\(request.hash)", params: ["products_ids": .value(productIds)]))
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
            Adapty.logSystemEvent(AdaptyAppleResponseParameters(
                methodName: "fetch_products",
                callId: "SKR\(request.hash)",
                params: [
                    "products_ids": .value(response.products.map { $0.productIdentifier }),
                    "invalid_products": .valueOrNil(response.invalidProductIdentifiers),
                ]
            ))

            if response.products.isEmpty {
                Log.verbose("SK1ProductsFetcher: SKProductsResponse don't have any product")
            }

            for product in response.products {
                Log.verbose("SK1ProductsFetcher: found product \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
            }

            guard let self else { return }
            if !response.invalidProductIdentifiers.isEmpty {
                Log.warn("SK1ProductsFetcher: InvalidProductIdentifiers: \(response.invalidProductIdentifiers.joined(separator: ", "))")
            }

            guard let productIds = self.requests[request]?.productIds else {
                Log.error("SK1ProductsFetcher: Not found SKRequest in self.requests")
                return
            }

            self.requests.removeValue(forKey: request)

            guard let handlers = self.completionHandlers.removeValue(forKey: productIds) else {
                Log.error("SK1ProductsFetcher: Not found completionHandlers by productIds")
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
        Adapty.logSystemEvent(AdaptyAppleEventQueueHandlerParameters(
            eventName: "fetch_products_did_finish",
            callId: "SKR\(request.hash)"
        ))
        request.cancel()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        defer { request.cancel() }
        queue.async { [weak self] in
            Adapty.logSystemEvent(AdaptyAppleResponseParameters(
                methodName: "fetch_products",
                callId: "SKR\(request.hash)",
                error: "\(error.localizedDescription). Detail: \(error)"
            ))

            Log.error("SK1ProductsFetcher: Can't fetch products from Store \(error)")
            guard let self else { return }
            guard let (productIds, retryCount) = self.requests[request] else {
                Log.error("SK1ProductsFetcher: Not found SKRequest in self.requests")
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
                Log.error("SK1ProductsFetcher: Not found completionHandlers by productIds")
                return
            }

            let error = SKManagerError.requestSK1ProductsFailed(error).asAdaptyError
            for completion in handlers {
                completion(.failure(error))
            }
        }
    }
}

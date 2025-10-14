//
//  SK1ProductFetcher.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.10.2024
//

import StoreKit

private let log = Log.sk1ProductManager

actor SK1ProductFetcher {
    private let fetcher = _SK1ProductFetcher()

    func fetchProducts(ids productIds: Set<String>, retryCount: Int = 3) async throws(AdaptyError) -> [SK1Product] {
        try await withCheckedThrowingContinuation_ { continuation in
            fetcher.fetchProducts(productIdentifiers: productIds, retryCount: retryCount) { result in
                continuation.resume(with: result)
            }
        }
    }
}

private final class _SK1ProductFetcher: NSObject, @unchecked Sendable {
    private let queue = DispatchQueue(label: "Adapty.SDK.SK1ProductFetcher")
    private var requests = [Int: (productIds: Set<String>, retryCount: Int)]()
    private var completionHandlers = [Set<String>: [AdaptyResultCompletion<[SK1Product]>]]()

    func fetchProducts(productIdentifiers productIds: Set<String>, retryCount: Int = 3, _ completion: @escaping AdaptyResultCompletion<[SK1Product]>) {
        queue.async { [weak self] in
            guard let self else {
                completion(.failure(StoreKitManagerError.interrupted().asAdaptyError))
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
        log.verbose("Called fetch SK1Products:\(productIds) retryCount:\(retryCount)")
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        requests[request.hash] = (productIds: productIds, retryCount: retryCount)
        request.start()
        let stamp = "SKR\(request.hash)"
        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
            methodName: .fetchSK1Products,
            stamp: stamp,
            params: ["products_ids": productIds]
        ))
    }
}

extension _SK1ProductFetcher: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let requestHash = request.hash
        let stamp = "SKR\(requestHash)"
        queue.async { [weak self] in
            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .fetchSK1Products,
                stamp: stamp,
                params: [
                    "products_ids": response.products.map { $0.productIdentifier },
                    "invalid_products": response.invalidProductIdentifiers,
                ]
            ))

            if response.products.isEmpty {
                log.verbose("SKProductsResponse don't have any product")
            }

            for product in response.products {
                log.verbose("Found product \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
            }

            guard let self else { return }
            if response.invalidProductIdentifiers.isNotEmpty {
                log.warn("InvalidProductIdentifiers: \(response.invalidProductIdentifiers.joined(separator: ", "))")
            }

            guard let productIds = self.requests[requestHash]?.productIds else {
                log.error("Not found SKRequest in self.requests")
                return
            }

            self.requests.removeValue(forKey: requestHash)

            guard let handlers = self.completionHandlers.removeValue(forKey: productIds) else {
                log.error("Not found completionHandlers by productIds")
                return
            }

            for completion in handlers {
                completion(.success(response.products))
            }
        }
    }

    func requestDidFinish(_ request: SKRequest) {
        let stamp = "SKR\(request.hash)"
        Adapty.trackSystemEvent(AdaptyAppleEventQueueHandlerParameters(
            eventName: "fetch_products_did_finish",
            stamp: stamp
        ))
        request.cancel()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        defer { request.cancel() }
        let requestHash = request.hash
        let stamp = "SKR\(requestHash)"
        queue.async { [weak self] in
            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .fetchSK1Products,
                stamp: stamp,
                error: "\(error.localizedDescription). Detail: \(error)"
            ))

            log.error("Can't fetch products from Store \(error)")
            guard let self else { return }
            guard let (productIds, retryCount) = self.requests[requestHash] else {
                log.error("Not found SKRequest in self.requests")
                return
            }

            guard retryCount <= 0 else {
                self.queue.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                    self?.startRequest(productIds, retryCount: retryCount - 1)
                }
                return
            }

            self.requests.removeValue(forKey: requestHash)

            guard let handlers = self.completionHandlers.removeValue(forKey: productIds) else {
                log.error("Not found completionHandlers by productIds")
                return
            }

            let error = StoreKitManagerError.requestSK1ProductsFailed(error).asAdaptyError
            for completion in handlers {
                completion(.failure(error))
            }
        }
    }
}

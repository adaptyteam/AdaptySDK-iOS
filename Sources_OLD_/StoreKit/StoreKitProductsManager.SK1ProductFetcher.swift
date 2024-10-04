//
//  StoreKitProductsManager.SK1ProductFetcher.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import StoreKit

private let log = Log.Category(name: "StoreKitProductsManager")

extension StoreKitProductsManager where Product == SK1Product {
    final class SK1ProductsFetcher: NSObject, SKProductsRequestDelegate, @unchecked Sendable  {
        private typealias Completion = @Sendable (Result<SKProductsResponse, any Error>) -> Void

        private let queue = DispatchQueue(label: "Adapty.SDK.SK1ProductsFetcher")
        private var requests = [Int: (ids: Set<String>, retryCount: Int)]()
        private var completionHandlers = [Set<String>: [Completion]]()

        func fetchProducts(ids productIds: Set<String>, retryCount: Int = 3) async throws -> [SK1Product] {
            log.verbose("Called fetch SK1Products: \(productIds) retryCount:\(retryCount)")

            let stamp = Log.stamp
            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .fetchSK1Products,
                stamp: stamp,
                params: [
                    "products_ids": productIds,
                ]
            ))

            let sk1Products: [SK1Product]
            do {
                let response = try await withCheckedThrowingContinuation { continuation in
                    fetchProducts(ids: productIds, retryCount: retryCount) { result in
                        continuation.resume(with: result)
                    }
                }
                sk1Products = response.products
                
                if !response.invalidProductIdentifiers.isEmpty {
                    log.warn("Invalid Sk1Product Identifiers: \(response.invalidProductIdentifiers.joined(separator: ", "))")
                }
                
            } catch {
                log.error("Can't fetch SK1Products from Store \(error)")

                await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                    methodName: .fetchSK2Products,
                    stamp: stamp,
                    error: "\(error.localizedDescription). Detail: \(error)"
                ))

                throw StoreKitManagerError.requestSK2ProductsFailed(error).asAdaptyError
            }

            if sk1Products.isEmpty {
                log.verbose("fetch SK1Products result is empty")
            }

            for sk1Product in sk1Products {
                log.verbose("Found SK1Product \(sk1Product.productIdentifier) \(sk1Product.localizedTitle) \(sk1Product.price)")
            }

            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .fetchSK2Products,
                stamp: stamp,
                params: [
                    "products_ids": sk1Products.map { $0.id },
                ]
            ))

            return sk1Products
        }

        private func fetchProducts(ids productIds: Set<String>, retryCount: Int = 3, _ completion: @escaping Completion) {
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
            let request = SKProductsRequest(productIdentifiers: productIds)
            request.delegate = self
            requests[request.hash] = (ids: productIds, retryCount: retryCount)
            request.start()
        }

        func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
            queue.async { [weak self] in
                guard let self else { return }
       
                guard let productIds = self.requests[request.hash]?.ids else {
                    log.error(" Not found SKRequest in self.requests")
                    return
                }

                self.requests.removeValue(forKey: request.hash)

                guard let handlers = self.completionHandlers.removeValue(forKey: productIds) else {
                    log.error("Not found completionHandlers by productIds")
                    return
                }

                for completion in handlers {
                    completion(.success(response))
                }
            }
        }

        func request(_ request: SKRequest, didFailWithError error: Error) {
            defer { request.cancel() }
            queue.async { [weak self] in
                guard let self else { return }
                guard let (productIds, retryCount) = self.requests[request.hash] else {
                    log.error("Not found SKRequest in self.requests")
                    return
                }

                guard retryCount <= 0 else {
                    self.queue.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                        self?.startRequest(productIds, retryCount: retryCount - 1)
                    }
                    return
                }

                self.requests.removeValue(forKey: request.hash)

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

        func requestDidFinish(_ request: SKRequest) {
            Adapty.trackSystemEvent(AdaptyAppleEventQueueHandlerParameters(
                eventName: "fetch_products_did_finish",
                stamp: "SKR\(request.hash)"
            ))
            request.cancel()
        }
    }
}

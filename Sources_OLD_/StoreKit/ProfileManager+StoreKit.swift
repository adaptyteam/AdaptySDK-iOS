//
//  ProfileManager+StoreKit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import StoreKit

extension ProfileManager {
    func setVariationId(_ variationId: String, forTransactionId transactionId: String) async throws {
        sdk.httpSession.performSetTransactionVariationIdRequest(profileId: profileId, transactionId: transactionId, variationId: variationId, completion)
    }

    func setVariationId(_ variationId: String, forPurchasedTransaction transaction: SK1Transaction) async throws {
        guard transaction.transactionState == .purchased || transaction.transactionState == .restored,
              let transactionIdentifier = transaction.transactionIdentifier else {
            completion(.wrongParamPurchasedTransaction())
            return
        }

        sdk.skProductsManager.fillPurchasedTransaction(variationId: variationId, purchasedSK1Transaction: (transaction, transactionIdentifier)) { [weak self] purchasedTransaction in

            guard let self, self.isActive else {
                completion(.profileWasChanged())
                return
            }

            self.sdk.validatePurchase(transaction: purchasedTransaction, reason: .setVariation) { completion($0.error) }
        }
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func setVariationId(_ variationId: String, forPurchasedTransaction transaction: SK2Transaction) async throws {
        sdk.skProductsManager.fillPurchasedTransaction(variationId: variationId, purchasedSK2Transaction: transaction) { [weak self] purchasedTransaction in

            guard let self, self.isActive else {
                completion(.profileWasChanged())
                return
            }

            self.sdk.validatePurchase(transaction: purchasedTransaction, reason: .setVariation) { completion($0.error) }
        }
    }

    func getBackendProductStates(vendorProductIds: [String]) async throws -> [BackendProductState] {
        guard !sdk.profileStorage.syncedTransactions else {
            fetch(vendorProductIds: vendorProductIds, completion)
            return
        }
        sdk.syncTransactions(refreshReceiptIfEmpty: true) { result in
            if let error = result.error {
                completion(.failure(error))
                return
            }
            fetch(vendorProductIds: vendorProductIds, completion)
        }

        func fetch(vendorProductIds: [String], _ completion: @escaping AdaptyResultCompletion<[BackendProductState]>) {
            sdk.httpSession.performFetchProductStatesRequest(profileId: profileId, responseHash: productStatesCache.productsHash) { [weak self] (result: AdaptyResult<VH<[BackendProductState]?>>) in

                guard let self, self.isActive else {
                    completion(.failure(.profileWasChanged()))
                    return
                }

                switch result {
                case let .failure(error):

                    let value = self.productStatesCache.getBackendProductStates(byIds: vendorProductIds)
                    guard !value.isEmpty else {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(value))
                case let .success(products):
                    self.productStatesCache.setBackendProductStates(products.flatValue())
                    completion(.success(self.productStatesCache.getBackendProductStates(byIds: vendorProductIds)))
                }
            }
        }
    }
}

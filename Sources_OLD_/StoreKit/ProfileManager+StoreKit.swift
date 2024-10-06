//
//  ProfileManager+StoreKit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import StoreKit

extension ProfileManager {
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

//
//  AdaptyProfileManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import StoreKit

final class AdaptyProfileManager {
    let manager: Adapty
    let profileId: String
    var profile: VH<AdaptyProfile>
    let paywallsCache: PaywallsCache
    let productStatesCache: ProductStatesCache
    var onceSentEnvironment: SendedEnvironment

    var isActive: Bool = true

    init(
        manager: Adapty,
        paywallStorage: PaywallsStorage,
        productStorage: BackendProductStatesStorage,
        profile: VH<AdaptyProfile>,
        sendedEnvironment: SendedEnvironment
    ) {
        self.manager = manager
        profileId = profile.value.profileId
        self.profile = profile
        paywallsCache = PaywallsCache(storage: paywallStorage, profileId: profileId)
        productStatesCache = ProductStatesCache(storage: productStorage)

        manager.updateASATokenIfNeed(for: profile)

        let storage = manager.profileStorage
        self.onceSentEnvironment = sendedEnvironment

        if sendedEnvironment == .dont {
            getProfile { _ in }
        } else if !storage.syncedTransactions {
            manager.syncTransactions(refreshReceiptIfEmpty: true) { _ in }
        }

        Adapty.callDelegate { $0.didLoadLatestProfile(profile.value) }
    }
}


extension AdaptyProfileManager {
    func updateProfileParameters(_ params: AdaptyProfileParameters, _ completion: @escaping AdaptyErrorCompletion) {
        syncProfile(params: params) { completion($0.error) }
    }

    func getProfile(_ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        syncProfile(params: nil) { [weak self] result in
            let out: AdaptyResult<AdaptyProfile>
            defer { completion(out) }

            guard let self, self.isActive else {
                out = .failure(.profileWasChanged())
                return
            }

            out = result.flatMapError { _ in
                .success(self.profile.value)
            }
        }

        if !manager.profileStorage.syncedTransactions {
            manager.syncTransactions(refreshReceiptIfEmpty: true) { _ in }
        }
    }

    private func syncProfile(params: AdaptyProfileParameters?, _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        let environmentMeta = onceSentEnvironment.getValueIfNeedSend(
            analyticsDisabled: (params?.analyticsDisabled ?? false) || manager.profileStorage.externalAnalyticsDisabled
        )

        let old = profile.value

        manager.httpSession.performSyncProfileRequest(
            profileId: profileId,
            parameters: params,
            environmentMeta: environmentMeta,
            responseHash: profile.hash
        ) { [weak self] result in
            completion(result
                .do {
                    if let environmentMeta {
                        self?.onceSentEnvironment = environmentMeta.idfa == nil ? .withoutIdfa : .withIdfa
                    }
                    self?.saveResponse($0.flatValue())
                }
                .map {
                    $0.value ?? old
                }
            )
        }
    }

    internal func saveResponse(_ newProfile: VH<AdaptyProfile>?) {
        guard isActive,
              let newProfile,
              profile.value.profileId == newProfile.value.profileId,
              profile.value.version <= newProfile.value.version
        else { return }

        if let oldHash = profile.hash,
           let newHash = newProfile.hash,
           oldHash == newHash { return }

        profile = newProfile
        manager.profileStorage.setProfile(newProfile)
        Adapty.callDelegate { $0.didLoadLatestProfile(newProfile.value) }
    }

    func setVariationId(_ variationId: String, forTransactionId transactionId: String, _ completion: @escaping AdaptyErrorCompletion) {
        manager.httpSession.performSetTransactionVariationIdRequest(profileId: profileId, transactionId: transactionId, variationId: variationId, completion)
    }

    func setVariationId(_ variationId: String, forPurchasedTransaction transaction: SK1Transaction, _ completion: @escaping AdaptyErrorCompletion) {
        guard transaction.transactionState == .purchased || transaction.transactionState == .restored,
              let transactionIdentifier = transaction.transactionIdentifier else {
            completion(.wrongParamPurchasedTransaction())
            return
        }

        manager.skProductsManager.fillPurchasedTransaction(variationId: variationId, purchasedSK1Transaction: (transaction, transactionIdentifier)) { [weak self] purchasedTransaction in

            guard let self, self.isActive else {
                completion(.profileWasChanged())
                return
            }

            self.manager.validatePurchase(transaction: purchasedTransaction, reason: .setVariation) { completion($0.error) }
        }
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func setVariationId(_ variationId: String, forPurchasedTransaction transaction: SK2Transaction, _ completion: @escaping AdaptyErrorCompletion) {
        manager.skProductsManager.fillPurchasedTransaction(variationId: variationId, purchasedSK2Transaction: transaction) { [weak self] purchasedTransaction in

            guard let self, self.isActive else {
                completion(.profileWasChanged())
                return
            }

            self.manager.validatePurchase(transaction: purchasedTransaction, reason: .setVariation) { completion($0.error) }
        }
    }

    func getBackendProductStates(vendorProductIds: [String], _ completion: @escaping AdaptyResultCompletion<[BackendProductState]>) {
        guard !manager.profileStorage.syncedTransactions else {
            fetch(vendorProductIds: vendorProductIds, completion)
            return
        }
        manager.syncTransactions(refreshReceiptIfEmpty: true) { result in
            if let error = result.error {
                completion(.failure(error))
                return
            }
            fetch(vendorProductIds: vendorProductIds, completion)
        }

        func fetch(vendorProductIds: [String], _ completion: @escaping AdaptyResultCompletion<[BackendProductState]>) {
            manager.httpSession.performFetchProductStatesRequest(profileId: profileId, responseHash: productStatesCache.productsHash) { [weak self] (result: AdaptyResult<VH<[BackendProductState]?>>) in

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

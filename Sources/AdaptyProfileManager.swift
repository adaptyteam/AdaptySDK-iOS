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

    var isActive: Bool = true

    init(
        manager: Adapty,
        paywallStorage: PaywallsStorage,
        productStorage: BackendProductStatesStorage,
        profile: VH<AdaptyProfile>
    ) {
        self.manager = manager
        profileId = profile.value.profileId
        self.profile = profile
        paywallsCache = PaywallsCache(storage: paywallStorage)
        productStatesCache = ProductStatesCache(storage: productStorage)

        manager.updateASATokenIfNeed(for: profile)
        if !manager.profileStorage.syncedTransactions {
            manager.syncTransactions(refreshReceiptIfEmpty: true) { _ in }
        }
        Adapty.callDelegate { $0.didLoadLatestProfile(profile.value) }
    }
}

extension AdaptyProfileManager {
    func updateProfile(params: AdaptyProfileParameters, _ completion: @escaping AdaptyErrorCompletion) {
        _updateProfile(params: params, sendEnvironmentMeta: .dont) { completion($0.error) }
    }

    func getProfile(_ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        let completion: AdaptyResultCompletion<AdaptyProfile> = { [weak self] result in
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

        guard !manager.onceSentEnvironment else {
            _getProfile(completion)
            return
        }
        let storage = manager.profileStorage
        let analyticsDisabled = storage.externalAnalyticsDisabled
        if !storage.syncedTransactions {
            manager.syncTransactions(refreshReceiptIfEmpty: true) { _ in }
        }

        _updateProfile(params: nil, sendEnvironmentMeta: analyticsDisabled ? .withoutAnalytics : .withAnalytics, completion)
    }

    private func _updateProfile(params: AdaptyProfileParameters?, sendEnvironmentMeta: Backend.Request.SendEnvironment, _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        let old = profile.value
        manager.httpSession.performUpdateProfileRequest(profileId: profileId, parameters: params, sendEnvironmentMeta: sendEnvironmentMeta, responseHash: profile.hash) { [weak self] result in
            completion(result
                .do {
                    self?.manager.onceSentEnvironment = true
                    self?.saveResponse($0.flatValue())
                }
                .map {
                    $0.value ?? old
                }
            )
        }
    }

    private func _getProfile(_ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        let old = profile.value
        manager.httpSession.performFetchProfileRequest(profileId: profileId, responseHash: profile.hash) { [weak self] result in
            completion(result
                .do {
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
            _getBackendProductStates(vendorProductIds: vendorProductIds, completion)
            return
        }
        manager.syncTransactions(refreshReceiptIfEmpty: true) { [weak self] result in
            if let error = result.error {
                completion(.failure(error))
                return
            }

            guard let self, self.isActive else {
                completion(.failure(.profileWasChanged()))
                return
            }

            self._getBackendProductStates(vendorProductIds: vendorProductIds, completion)
        }
    }

    private func _getBackendProductStates(vendorProductIds: [String], _ completion: @escaping AdaptyResultCompletion<[BackendProductState]>) {
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

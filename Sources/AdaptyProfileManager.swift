//
//  AdaptyManager.swift
//  Adapty
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

    init(manager: Adapty,
         paywallStorage: PaywallsStorage,
         productStorage: BackendProductStatesStorage,
         profile: VH<AdaptyProfile>) {
        self.manager = manager
        profileId = profile.value.profileId
        self.profile = profile
        paywallsCache = PaywallsCache(storage: paywallStorage)
        productStatesCache = ProductStatesCache(storage: productStorage)

        manager.updateAppleSearchAdsAttribution()
        if !manager.profileStorage.syncedBundleReceipt {
            manager.validateReceipt(refreshIfEmpty: true) { _ in }
        }
        Adapty.callDelegate { $0.didLoadLatestProfile(profile.value) }
    }
}

extension AdaptyProfileManager {
    func updateProfile(params: AdaptyProfileParameters, _ completion: @escaping AdaptyErrorCompletion) {
        _updateProfile(params: params, sendEnvironmentMeta: .dont) { completion($0.error) }
    }

    private func _updateProfile(params: AdaptyProfileParameters?, sendEnvironmentMeta: Backend.Request.SendEnvironment, _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        let old = profile.value
        manager.httpSession.performUpdateProfileRequest(profileId: profileId, parameters: params, sendEnvironmentMeta: sendEnvironmentMeta, responseHash: profile.hash) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(profile):
                self?.manager.onceSentEnvironment = true
                if let value = profile.value, let self = self, self.isActive {
                    self.saveResponse(profile.withValue(value))
                }
                completion(.success(profile.value ?? old))
            }
        }
    }

    private func _getProfile(_ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        let old = profile.value
        manager.httpSession.performFetchProfileRequest(profileId: profileId, responseHash: profile.hash) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(profile):
                if let value = profile.value, let self = self, self.isActive {
                    self.saveResponse(profile.withValue(value))
                }
                completion(.success(profile.value ?? old))
            }
        }
    }

    func getProfile(_ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        let completion: AdaptyResultCompletion<AdaptyProfile> = { [weak self] result in

            guard let self = self, self.isActive else {
                completion(.failure(.profileWasChanged()))
                return
            }

            if result.error != nil {
                completion(.success(self.profile.value))
            } else {
                completion(result)
            }
        }

        guard !manager.onceSentEnvironment else {
            _getProfile(completion)
            return
        }
        let storage = manager.profileStorage
        let analyticsDisabled = storage.externalAnalyticsDisabled
        if !storage.syncedBundleReceipt {
            manager.validateReceipt(refreshIfEmpty: true) { _ in }
        }

        _updateProfile(params: nil, sendEnvironmentMeta: analyticsDisabled ? .withoutAnalytics : .withAnalytics, completion)
    }

    func saveResponse(_ newProfile: VH<AdaptyProfile>?) {
        guard isActive,
              let newProfile = newProfile,
              profile.value.profileId == newProfile.value.profileId
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
        guard transaction.transactionState == .purchased || transaction.transactionState == .restored else {
            completion(.wrongParamPurchasedTransaction())
            return
        }
        manager.skProductsManager.fetchPurchaseProductInfo(variationId: variationId, purchasedTransaction: transaction) { [weak self] purchaseProductInfo in

            guard let self = self, self.isActive else {
                completion(.profileWasChanged())
                return
            }

            self.manager.validatePurchase(info: purchaseProductInfo) { completion($0.error) }
        }
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    func setVariationId(_ variationId: String, forPurchasedTransaction transaction: SK2Transaction, _ completion: @escaping AdaptyErrorCompletion) {
        manager.skProductsManager.fetchPurchaseProductInfo(variationId: variationId, purchasedTransaction: transaction) { [weak self] purchaseProductInfo in

            guard let self = self, self.isActive else {
                completion(.profileWasChanged())
                return
            }

            self.manager.validatePurchase(info: purchaseProductInfo) { completion($0.error) }
        }
    }

    func getBackendProductStates(vendorProductIds: [String], _ completion: @escaping AdaptyResultCompletion<[BackendProductState]>) {
        guard !manager.profileStorage.syncedBundleReceipt else {
            _getBackendProductStates(vendorProductIds: vendorProductIds, completion)
            return
        }
        manager.validateReceipt(refreshIfEmpty: true) { [weak self] result in
            if let error = result.error {
                completion(.failure(error))
                return
            }

            guard let self = self, self.isActive else {
                completion(.failure(.profileWasChanged()))
                return
            }

            self._getBackendProductStates(vendorProductIds: vendorProductIds, completion)
        }
    }

    private func _getBackendProductStates(vendorProductIds: [String], _ completion: @escaping AdaptyResultCompletion<[BackendProductState]>) {
        manager.httpSession.performFetchProductStatesRequest(profileId: profileId, responseHash: productStatesCache.productsHash) { [weak self] (result: AdaptyResult<VH<[BackendProductState]?>>) in

            guard let self = self, self.isActive else {
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
                if let value = products.value {
                    self.productStatesCache.setBackendProductStates(products.withValue(value))
                }
                completion(.success(self.productStatesCache.getBackendProductStates(byIds: vendorProductIds)))
            }
        }
    }
}

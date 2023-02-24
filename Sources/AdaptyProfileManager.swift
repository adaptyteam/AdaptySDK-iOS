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
    let productsCache: ProductsCache

    var isActive: Bool = true

    init(manager: Adapty,
         paywallStorage: PaywallsStorage,
         productStorage: BackendProductsStorage,
         profile: VH<AdaptyProfile>) {
        self.manager = manager
        profileId = profile.value.profileId
        self.profile = profile
        paywallsCache = PaywallsCache(storage: paywallStorage)
        productsCache = ProductsCache(storage: productStorage)

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

    private func _updateProfile(params: AdaptyProfileParameters?, sendEnvironmentMeta: UpdateProfileRequest.SendEnvironment, _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        let old = profile.value
        manager.httpSession.performUpdateProfileRequest(profileId: profileId, parameters: params, sendEnvironmentMeta: sendEnvironmentMeta, responseHash: profile.hash) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(profile):
                self?.manager.onceSentEnvironment = true
                if let value = profile.value, let self = self, self.isActive {
                    self.saveResponse(VH(value, hash: profile.hash))
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
                    self.saveResponse(VH(value, hash: profile.hash))
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

    func getPaywall(_ id: String, _ locale: String?, _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        let old = paywallsCache.getPaywallByLocaleOrDefault(locale, withId: id)
        let syncedBundleReceipt = manager.profileStorage.syncedBundleReceipt
        manager.httpSession.performFetchPaywallRequest(paywallId: id,
                                                       locale: locale,
                                                       profileId: profileId,
                                                       responseHash: old?.hash,
                                                       syncedBundleReceipt: syncedBundleReceipt) {
            [weak self] (result: AdaptyResult<VH<AdaptyPaywall?>>) in

            guard let self = self, self.isActive else {
                completion(.failure(.profileWasChanged()))
                return
            }

            switch result {
            case let .failure(error):
                guard let value = self.paywallsCache.getPaywallWithFallback(byId: id, locale: locale) ?? old?.value
                else {
                    completion(.failure(error))
                    return
                }
                completion(.success(value))
            case let .success(paywall):

                if let value = paywall.value {
                    completion(.success(self.paywallsCache.savedPaywall(VH(value, hash: paywall.hash))))
                    return
                }

                if let value = old?.value {
                    completion(.success(value))
                    return
                }

                if let value = self.paywallsCache.getPaywallWithFallback(byId: id, locale: locale) {
                    completion(.success(value))
                    return
                }

                completion(.failure(.cacheHasNotPaywall()))
            }
        }
    }

    func getPaywallProducts(paywall: AdaptyPaywall, fetchPolicy: AdaptyProductsFetchPolicy = .default, _ completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProduct]>) {
        Log.debug("call getPaywallProducts with params paywall.id: \(paywall.id) fetchPolicy: \(fetchPolicy)")
        switch fetchPolicy {
        case .default:
            getPaywallProducts(paywall: paywall, completion)
        case .waitForReceiptValidation:
            guard !manager.profileStorage.syncedBundleReceipt else {
                getPaywallProducts(paywall: paywall, completion)
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

                self.getPaywallProducts(paywall: paywall, completion)
            }
        }
    }

    func getPaywallProducts(paywall: AdaptyPaywall, _ completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProduct]>) {
        getPaywallProducts(paywall: paywall) { [weak self] (result: AdaptyResult<[BackendProduct]>) in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(backendProducts):
                guard let manager = self?.manager else {
                    completion(.failure(.profileWasChanged()))
                    return
                }
                manager.skProductsManager.getPaywallProducts(paywall: paywall, backendProducts, completion)
            }
        }
    }

    private func getPaywallProducts(paywall: AdaptyPaywall, _ completion: @escaping AdaptyResultCompletion<[BackendProduct]>) {
        let vendorProductIds = paywall.vendorProductIds
        let syncedBundleReceipt = manager.profileStorage.syncedBundleReceipt
        manager.httpSession.performFetchAllProductsRequest(profileId: profileId, responseHash: productsCache.productsHash, syncedBundleReceipt: syncedBundleReceipt) { [weak self] (result: AdaptyResult<VH<[BackendProduct]?>>) in

            guard let self = self, self.isActive else {
                completion(.failure(.profileWasChanged()))
                return
            }

            switch result {
            case let .failure(error):

                let value = self.productsCache.getProductsWithFallback(byIds: vendorProductIds)
                guard !value.isEmpty else {
                    completion(.failure(error))
                    return
                }
                completion(.success(value))
            case let .success(products):
                if let value = products.value {
                    self.productsCache.setProducts(VH(value, hash: products.hash))
                }
                completion(.success(self.productsCache.getProductsWithFallback(byIds: vendorProductIds)))
            }
        }
    }
}

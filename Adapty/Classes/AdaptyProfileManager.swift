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
    var profile: VH<Profile>
    let paywallsCache: PaywallsCache
    let productsCache: ProductsCache

    var isActive: Bool = true

    init(manager: Adapty,
         paywallStorage: PaywallsStorage,
         productStorage: BackendProductsStorage,
         profile: VH<Profile>) {
        self.manager = manager
        profileId = profile.value.profileId
        self.profile = profile
        paywallsCache = PaywallsCache(storage: paywallStorage)
        productsCache = ProductsCache(storage: productStorage)

        manager.updateAppleSearchAdsAttribution()
        if !manager.profileStorage.syncedBundleReceipt {
            manager.validateReceipt(purchaseProductInfo: nil, refreshIfEmpty: true) { _ in }
        }
        Adapty.callDelegate { $0.didLoadLatestProfile(profile.value) }
    }
}

extension AdaptyProfileManager {
    func updateProfile(params: ProfileParameters, _ completion: @escaping ErrorCompletion) {
        _updateProfile(params: params, sendEnvironmentMeta: .dont) { completion($0.error) }
    }

    private func _updateProfile(params: ProfileParameters?, sendEnvironmentMeta: UpdateProfileRequest.SendEnvironment, _ completion: @escaping ResultCompletion<Profile>) {
        let old = profile.value
        manager.httpSession.performUpdateProfileRequest(profileId: profileId, parameters: params, sendEnvironmentMeta: sendEnvironmentMeta, responseHash: profile.hash) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(profile):
                self?.manager.onceSendedEnvoriment = true
                if let value = profile.value, let self = self, self.isActive {
                    self.saveResponse(VH(value, hash: profile.hash))
                }
                completion(.success(profile.value ?? old))
            }
        }
    }

    private func _getProfile(_ completion: @escaping ResultCompletion<Profile>) {
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

    func getProfile(_ completion: @escaping ResultCompletion<Profile>) {
        let completion: ResultCompletion<Profile> = { [weak self] result in

            guard let self = self, self.isActive else {
                completion(.failure(AdaptyError.profileWasChanged()))
                return
            }

            if result.error != nil {
                completion(.success(self.profile.value))
            } else {
                completion(result)
            }
        }

        guard !manager.onceSendedEnvoriment else {
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

    func saveResponse(_ newProfile: VH<Profile>?) {
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

    func setVariationId(_ variationId: String, forTransactionId transactionId: String, _ completion: @escaping ErrorCompletion) {
        manager.httpSession.performSetTransactionVariationIdRequest(profileId: profileId, transactionId: transactionId, variationId: variationId, completion)
    }

    func getPaywall(_ id: String, _ completion: @escaping ResultCompletion<Paywall>) {
        let old = paywallsCache.getPaywall(byId: id)
        let syncedBundleReceipt = manager.profileStorage.syncedBundleReceipt
        manager.httpSession.performFetchPaywallRequest(paywallId: id,
                                                       profileId: profileId,
                                                       responseHash: old?.hash,
                                                       syncedBundleReceipt: syncedBundleReceipt) {
            [weak self] (result: AdaptyResult<VH<Paywall?>>) in

            guard let self = self, self.isActive else {
                completion(.failure(AdaptyError.profileWasChanged()))
                return
            }

            switch result {
            case let .failure(error):
                guard let value = self.paywallsCache.getPaywallWithFallback(byId: id) else {
                    completion(.failure(error))
                    return
                }
                completion(.success(value))
            case let .success(paywall):

                if let value = paywall.value {
                    self.paywallsCache.setPaywall(VH(value, hash: paywall.hash))
                    completion(.success(value))
                    return
                }

                if let value = self.paywallsCache.getPaywallWithFallback(byId: id) ?? old?.value {
                    completion(.success(value))
                    return
                }

                completion(.failure(AdaptyError.cacheHasNotPaywall()))
            }
        }
    }

    func getPaywallProducts(paywall: Paywall, fetchPolicy: Adapty.ProductsFetchPolicy = .default, _ completion: @escaping ResultCompletion<[PaywallProduct]>) {
        switch fetchPolicy {
        case .default:
            getPaywallProducts(paywall: paywall, completion)
        case .waitForReceiptValidation where manager.profileStorage.syncedBundleReceipt:
            getPaywallProducts(paywall: paywall, completion)
        case .waitForReceiptValidation:
            manager.validateReceipt(refreshIfEmpty: true) { [weak self] result in
                if let error = result.error {
                    completion(.failure(error))
                    return
                }

                guard let self = self, self.isActive else {
                    completion(.failure(AdaptyError.profileWasChanged()))
                    return
                }

                self.getPaywallProducts(paywall: paywall, completion)
            }
        }
    }

    func getPaywallProducts(paywall: Paywall, _ completion: @escaping ResultCompletion<[PaywallProduct]>) {
        getPaywallProducts(paywall: paywall) { [weak self] (result: AdaptyResult<[BackendProduct]>) in
            switch result {
            case .failure:
                completion(.success([]))
            case let .success(backendProducts):
                guard let manager = self?.manager else {
                    completion(.success([]))
                    return
                }
                manager.skProductsManager.fetchProducts(productIdentifiers: Set(backendProducts.map { $0.vendorId })) {
                    completion($0.map { (skProducts: [SKProduct]) -> [PaywallProduct] in
                        backendProducts.compactMap { product in
                            guard let sk = skProducts.first(where: { $0.productIdentifier == product.vendorId }) else {
                                return nil
                            }
                            return PaywallProduct(paywall: paywall, product: product, skProduct: sk)
                        }
                    })
                }
            }
        }
    }

    private func getPaywallProducts(paywall: Paywall, _ completion: @escaping ResultCompletion<[BackendProduct]>) {
        let vendorProductIds = paywall.vendorProductIds
        let syncedBundleReceipt = manager.profileStorage.syncedBundleReceipt
        manager.httpSession.performFetchAllProductsRequest(profileId: profileId, responseHash: productsCache.productsHash, syncedBundleReceipt: syncedBundleReceipt) { [weak self] (result: AdaptyResult<VH<[BackendProduct]?>>) in

            guard let self = self, self.isActive else {
                completion(.failure(AdaptyError.profileWasChanged()))
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
                    completion(.success(value))
                    return
                }
                completion(.success(self.productsCache.getProductsWithFallback(byIds: vendorProductIds)))
            }
        }
    }
}

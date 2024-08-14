//
//  Adapty+UntargetedPaywalls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.08.2024
//

import Foundation

extension Adapty {
    public static func getPaywallForDefaultAudience(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPaywall.FetchPolicy = .default,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        getPaywallForDefaultAudience(placementId, locale: locale.map { AdaptyLocale(id: $0) } ?? .defaultPaywallLocale, withFetchPolicy: fetchPolicy, completion)
    }

    static func getPaywallForDefaultAudience(
        _ placementId: String,
        locale: AdaptyLocale,
        withFetchPolicy fetchPolicy: AdaptyPaywall.FetchPolicy,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        let logParams: EventParameters = [
            "placement_id": .value(placementId),
            "locale": .value(locale),
            "fetch_policy": .value(fetchPolicy),
        ]

        Adapty.async(completion, logName: "get_untargeted_paywall", logParams: logParams) { manager, completion in
            let completion: (AdaptyResult<AdaptyPaywall>) -> Void = { result in
                _ = result.do {
                    $0.sendImageUrlsToObserver()
                }
                completion(result)
            }

            if let profileManager = manager.state.initialized {
                profileManager.getUntargetedPaywall(placementId, locale, withFetchPolicy: fetchPolicy, completion)
            } else {
                manager.getUntargetedPaywall(placementId, locale, completion)
            }
        }
    }

    private func getUntargetedPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        let profileId = profileStorage.profileId
        httpConfigsSession.performFetchUntargetedPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            cached: nil,
            disableServerCache: false // don't loaded profile
        ) { (result: AdaptyResult<AdaptyPaywallChosen>) in
            completion(
                result
                    .flatMapError { error in
                        if let fallback = Adapty.Configuration.fallbackPaywalls?.getPaywall(byPlacmentId: placementId, profileId: profileId) {
                            .success(fallback)
                        } else {
                            .failure(error)
                        }
                    }
                    .map {
                        Adapty.logIfNeed($0)
                        return $0.value
                    }
            )
        }
    }
}

private extension AdaptyProfileManager {
    func getUntargetedPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale,
        withFetchPolicy fetchPolicy: AdaptyPaywall.FetchPolicy,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        if let cached = paywallsCache.getPaywallByLocale(locale, orDefaultLocale: true, withPlacementId: placementId),
           fetchPolicy.canReturn(cached) {
            completion(.success(cached.value))
            getUntargetedPaywall(placementId, locale) { _ in }
        } else {
            getUntargetedPaywall(placementId, locale, completion)
        }
    }

    private func getUntargetedPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        let cached = paywallsCache.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId)?.value
        manager.httpConfigsSession.performFetchUntargetedPaywallVariationsRequest(
            apiKeyPrefix: manager.apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            cached: cached,
            disableServerCache: profile.value.isTestUser
        ) { [weak self] (result: AdaptyResult<AdaptyPaywallChosen>) in

            switch result {
            case let .failure(error):

                let _self = (self?.isActive ?? false) ? self : nil

                guard let value = _self?.paywallsCache.getPaywallWithFallback(byPlacementId: placementId, locale: locale) else {
                    completion(.failure(error))
                    return
                }

                completion(.success(value))

            case var .success(paywall):

                if let self, self.isActive {
                    paywall = self.paywallsCache.savedPaywallChosen(paywall)
                }
                Adapty.logIfNeed(paywall)
                completion(.success(paywall.value))
            }
        }
    }
}

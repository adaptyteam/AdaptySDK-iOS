//
//  Adapty+Paywalls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.11.2023
//

import Foundation

extension Adapty {
    /// Adapty allows you remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without app releases.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - id: The identifier of the desired paywall. This is the value you specified when you created the paywall in the Adapty Dashboard.
    ///   - locale: The identifier of the paywall [localization](https://docs.adapty.io/docs/paywall#localizations).
    ///             This parameter is expected to be a language code composed of one or more subtags separated by the "-" character. The first subtag is for the language, the second one is for the region (The support for regions will be added later).
    ///             Example: "en" means English, "en-US" represents US English.
    ///             If the parameter is omitted, the paywall will be returned in the default locale.
    ///   - fetchPolicy:
    ///   - completion: A result containing the ``AdaptyPaywall`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    public static func getPaywall(_ id: String,
                                  locale: String? = nil,
                                  fetchPolicy: AdaptyPaywall.FetchPolicy = .default,
                                  _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        getPaywall( id, locale: locale.map { AdaptyLocale(id: $0) }, fetchPolicy: fetchPolicy, completion)
    }

    static func getPaywall(_ id: String,
                                  locale: AdaptyLocale? = nil,
                                  fetchPolicy: AdaptyPaywall.FetchPolicy = .default,
                                  _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        let logParams: EventParameters = [
            "paywall_id": .value(id),
            "locale": .valueOrNil(locale),
        ]
        async(completion, logName: "get_paywall", logParams: logParams) { manager, completion in
            let fallback = Adapty.Configuration.fallbackPaywalls?.paywalls[id]
            manager.getProfileManager(waitCreatingProfile: fallback == nil) { result in
                switch result {
                case let .success(profileManager):
                    profileManager.getPaywall(id, locale, fetchPolicy: fetchPolicy, completion)
                case let .failure(error):
                    guard error.isProfileCreateFailed, let paywall = fallback else {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(paywall))
                }
            }
        }
    }

    private func getFallbackPaywall(_ id: String, _ locale: AdaptyLocale?, _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        let httpSession = fallbackBackend.createHTTPSession(responseQueue: Adapty.underlayQueue)
        httpSession.performFetchFallbackPaywallRequest(apiKeyPrefix: apiKeyPrefix, paywallId: id, locale: locale, responseHash: nil) {
                [weak self] (result: AdaptyResult<VH<AdaptyPaywall>>) in

                guard let self = self else { return }

                switch result {
                case let .failure(error):
                    guard let value = self.paywallsCache.getPaywallWithFallback(byId: id, locale: locale) ?? old?.value
                    else {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(value))
                case let .success(paywall):

                    if let value = paywall.value ?? old?.value {
                        completion(.success(self.paywallsCache.savedPaywall(paywall.withValue(value))))
                        return
                    }


                    if let value = self.paywallsCache.getPaywallWithFallback(byId: id, locale: locale) {
                        completion(.success(value))
                        return
                    }

                    completion(.failure(.cacheHasNoPaywall()))
                }
            }
    }
}

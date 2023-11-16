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
                                  loadTimeout: TimeInterval = .defaultLoadPaywallTimeout,
                                  _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        getPaywall(id, locale: locale.map { AdaptyLocale(id: $0) }, withFetchPolicy: fetchPolicy, loadTimeout: loadTimeout, completion)
    }

    static func getPaywall(_ id: String,
                           locale: AdaptyLocale? = nil,
                           withFetchPolicy fetchPolicy: AdaptyPaywall.FetchPolicy,
                           loadTimeout: TimeInterval,
                           _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        let logParams: EventParameters = [
            "paywall_id": .value(id),
            "locale": .valueOrNil(locale),
            "fetch_policy": .value(fetchPolicy),
            "load_timeout": .value(loadTimeout),
        ]

        let loadTimeout = loadTimeout.allowedLoadPaywallTimeout.dispatchTimeInterval

        async(completion, logName: "get_paywall", logParams: logParams) { manager, completion in

            var isCompletionCalled = false

            let completion: AdaptyResultCompletion<AdaptyPaywall> = {
                guard !isCompletionCalled else { return }
                isCompletionCalled = true
                completion($0)
            }

            Adapty.underlayQueue.asyncAfter(deadline: .now() + loadTimeout - .milliseconds(500)) {
                manager.getFallbackPaywall(id, locale, completion)
            }

            manager.getProfileManager(waitCreatingProfile: false) { [weak manager] result in
                switch result {
                case let .success(profileManager):
                    profileManager.getPaywall(id, locale, withFetchPolicy: fetchPolicy, completion)
                case let .failure(error):
                    guard error.isProfileCreateFailed, let manager = manager else {
                        completion(.failure(error))
                        return
                    }
                    manager.getFallbackPaywall(id, locale, completion)
                }
            }
        }
    }

    fileprivate func getFallbackPaywall(_ id: String,
                                        _ locale: AdaptyLocale?,
                                        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        httpFallbackSession.performFetchFallbackPaywallRequest(apiKeyPrefix: apiKeyPrefix,
                                                               paywallId: id,
                                                               locale: locale) { result in
            completion(
                result
                    .map { paywall in
                        paywall.value
                    }
                    .flatMapError { error in
                        if let fallback = Adapty.Configuration.fallbackPaywalls?.paywalls[id] {
                            return .success(fallback)
                        } else {
                            return .failure(error)
                        }
                    }
            )
        }
    }
}

fileprivate extension AdaptyProfileManager {
    func getPaywall(_ id: String, _ locale: AdaptyLocale?, withFetchPolicy fetchPolicy: AdaptyPaywall.FetchPolicy, _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        if let cached = paywallsCache.getPaywallByLocale(locale, withId: id), fetchPolicy.canReturn(cached) {
            completion(.success(cached.value))
        } else {
            getPaywall(id, locale, completion)
        }
    }

    private func getPaywall(_ id: String,
                            _ locale: AdaptyLocale?,
                            _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        let old = paywallsCache.getPaywallByLocaleOrDefault(locale, withId: id)

        let locale = locale ?? AdaptyLocale.defaultPaywallLocale
        manager.httpSession.performFetchPaywallRequest(apiKeyPrefix: manager.apiKeyPrefix,
                                                       profileId: profileId,
                                                       paywallId: id,
                                                       locale: locale,
                                                       segmentId: profile.value.segmentId,
                                                       responseHash: old?.hash) {
            [weak self] (result: AdaptyResult<VH<AdaptyPaywall?>>) in

            switch result {
            case let .failure(error):

                guard let self = self, self.isActive else {
                    if let value = old?.value {
                        completion(.success(value))
                    } else {
                        completion(.failure(error))
                    }
                    return
                }

                if let httpError = error.wrapped as? HTTPError,
                   Backend.canUseFallbackServer(httpError) {
                    self.getFallbackPaywall(id, locale, cachedPaywall: old?.value, completion)
                    return
                }

                guard let value = self.paywallsCache.getPaywallWithFallback(byId: id, locale: locale) ?? old?.value
                else {
                    completion(.failure(error))
                    return
                }
                completion(.success(value))

            case let .success(paywall):

                guard let self = self, self.isActive else {
                    if let value = paywall.value ?? old?.value {
                        completion(.success(value))
                    } else {
                        completion(.failure(.cacheHasNoPaywall()))
                    }
                    return
                }

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

    private func getFallbackPaywall(_ id: String,
                                    _ locale: AdaptyLocale? = nil,
                                    cachedPaywall: AdaptyPaywall?,
                                    _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        manager.httpFallbackSession.performFetchFallbackPaywallRequest(
            apiKeyPrefix: manager.apiKeyPrefix,
            paywallId: id,
            locale: locale) { [weak self] (result: AdaptyResult<VH<AdaptyPaywall>>) in

                switch result {
                case let .failure(error):

                    let _self = (self?.isActive ?? false) ? self : nil

                    guard let value = _self?.paywallsCache.getPaywallWithFallback(byId: id, locale: locale) ?? cachedPaywall
                    else {
                        completion(.failure(error))
                        return
                    }

                    completion(.success(value))
                case let .success(paywall):
                    guard let self = self, self.isActive else {
                        completion(.success(paywall.value))
                        return
                    }
                    completion(.success(self.paywallsCache.savedPaywall(paywall)))
                }
            }
    }
}

extension TimeInterval {
    public static let defaultLoadPaywallTimeout: TimeInterval = 5.0
    static let minimumLoadPaywallTimeout: TimeInterval = 1.0

    var allowedLoadPaywallTimeout: TimeInterval {
        let minimum: TimeInterval = .minimumLoadPaywallTimeout
        guard self < minimum else { return self }
        Log.warn("The  paywall load timeout parameter cannot be less than \(minimum)s")
        return minimum
    }

    var dispatchTimeInterval: DispatchTimeInterval {
        let microseconds = Int64(self * TimeInterval(1000.0))
        return microseconds < Int.max ? .microseconds(Int(microseconds)) : .seconds(Int(self))
    }
}

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
    ///   - placementId: The identifier of the desired placement. This is the value you specified when you created the placement in the Adapty Dashboard.
    ///   - locale: The identifier of the paywall [localization](https://docs.adapty.io/docs/paywall#localizations).
    ///             This parameter is expected to be a language code composed of one or more subtags separated by the "-" character. The first subtag is for the language, the second one is for the region (The support for regions will be added later).
    ///             Example: "en" means English, "en-US" represents US English.
    ///             If the parameter is omitted, the paywall will be returned in the default locale.
    ///   - fetchPolicy:by default SDK will try to load data from server and will return cached data in case of failure. Otherwise use `.returnCacheDataElseLoad` to return cached data if it exists.
    ///   - loadTimeout: This value limits the timeout for this method. If the timeout is reached, cached data or local fallback will be returned.
    ///   - completion: A result containing the ``AdaptyPaywall`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    public static func getPaywall(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPaywall.FetchPolicy = .default,
        loadTimeout: TimeInterval = .defaultLoadPaywallTimeout,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        getPaywall(placementId, locale: locale.map { AdaptyLocale(id: $0) }, withFetchPolicy: fetchPolicy, loadTimeout: loadTimeout, completion)
    }

    static func getPaywall(
        _ placementId: String,
        locale: AdaptyLocale? = nil,
        withFetchPolicy fetchPolicy: AdaptyPaywall.FetchPolicy,
        loadTimeout: TimeInterval,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        let logParams: EventParameters = [
            "placement_id": .value(placementId),
            "locale": .valueOrNil(locale),
            "fetch_policy": .value(fetchPolicy),
            "load_timeout": .value(loadTimeout),
        ]

        Adapty.async(completion, logName: "get_paywall", logParams: logParams) { manager, completion in

            var isTerminationCalled = false
            var loadedProfileManager: AdaptyProfileManager?

            let termination: (AdaptyResult<AdaptyPaywall>) -> Void = { [weak manager] result in
                guard !isTerminationCalled else { return }
                isTerminationCalled = true

                guard case let .failure(error) = result, let manager else {
                    completion(result)
                    return
                }

                guard let profileManager = loadedProfileManager, profileManager.isActive else {
                    if error.canUseFallbackServer || error.isProfileCreateFailed {
                        manager.getFallbackPaywall(placementId, locale, completion)
                    } else {
                        completion(result)
                    }
                    return
                }

                guard !error.canUseFallbackServer else {
                    profileManager.getFallbackPaywall(placementId, locale, completion)
                    return
                }

                if let value = profileManager.paywallsCache.getPaywallWithFallback(byPlacementId: placementId, locale: locale) {
                    completion(.success(value))
                } else {
                    completion(result)
                }
            }

            manager.getProfileManager(waitCreatingProfile: false) { result in
                switch result {
                case let .success(profileManager):
                    loadedProfileManager = profileManager

                    profileManager.getPaywall(placementId, locale, withFetchPolicy: fetchPolicy) { result in
                        termination(result)
                    }
                case let .failure(error):
                    termination(.failure(error))
                }
            }

            let loadTimeout = loadTimeout.allowedLoadPaywallTimeout.dispatchTimeInterval

            if loadTimeout != .never, !isTerminationCalled {
                Adapty.underlayQueue.asyncAfter(deadline: .now() - .milliseconds(500) + loadTimeout) {
                    termination(.failure(.fetchPaywallTimeout()))
                }
            }
        }
    }

    fileprivate func getFallbackPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale?,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        httpFallbackSession.performFetchFallbackPaywallRequest(
            apiKeyPrefix: apiKeyPrefix,
            placementId: placementId,
            locale: locale
        ) { result in
            completion(
                result.map { paywall in
                    paywall.value
                }
                .flatMapError { error in
                    if let fallback = Adapty.Configuration.fallbackPaywalls?.paywallByPlacementId[placementId] {
                        .success(fallback)
                    } else {
                        .failure(error)
                    }
                }
            )
        }
    }
}

private extension AdaptyProfileManager {
    func getPaywall(_ placementId: String, _ locale: AdaptyLocale?, withFetchPolicy fetchPolicy: AdaptyPaywall.FetchPolicy, _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        if let cached = paywallsCache.getPaywallByLocale(locale, withPlacementId: placementId),
           fetchPolicy.canReturn(cached) {
            completion(.success(cached.value))
            getPaywall(placementId, locale) { _ in }
        } else {
            getPaywall(placementId, locale, completion)
        }
    }

    private func getPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale?,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        manager.httpSession.performFetchPaywallRequest(
            apiKeyPrefix: manager.apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            segmentId: profile.value.segmentId
        ) { [weak self] (result: AdaptyResult<VH<AdaptyPaywall>>) in
            completion(result.map {
                if let self, self.isActive {
                    self.paywallsCache.savedPaywall($0)
                } else {
                    $0.value
                }
            })
        }
    }

    func getFallbackPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale? = nil,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        manager.httpFallbackSession.performFetchFallbackPaywallRequest(
            apiKeyPrefix: manager.apiKeyPrefix,
            placementId: placementId,
            locale: locale
        ) { [weak self] (result: AdaptyResult<VH<AdaptyPaywall>>) in

            switch result {
            case let .failure(error):

                let _self = (self?.isActive ?? false) ? self : nil

                guard let value = _self?.paywallsCache.getPaywallWithFallback(byPlacementId: placementId, locale: locale) else {
                    completion(.failure(error))
                    return
                }

                completion(.success(value))

            case let .success(paywall):
                guard let self, self.isActive else {
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
        guard isNormal else { return .never }
        let milliseconds = Int64(self * TimeInterval(1000.0))
        return milliseconds < Int.max ? .milliseconds(Int(milliseconds)) : .seconds(Int(self))
    }
}

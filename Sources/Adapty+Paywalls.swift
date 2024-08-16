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
        getPaywall(placementId, locale: locale.map { AdaptyLocale(id: $0) } ?? .defaultPaywallLocale, withFetchPolicy: fetchPolicy, loadTimeout: loadTimeout, completion)
    }

    static func getPaywall(
        _ placementId: String,
        locale: AdaptyLocale,
        withFetchPolicy fetchPolicy: AdaptyPaywall.FetchPolicy,
        loadTimeout: TimeInterval,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
            "load_timeout": loadTimeout,
        ]

        Adapty.async(completion, logName: "get_paywall", logParams: logParams) { manager, completion in

            var isTerminationCalled = false
            var loadedProfileManager: AdaptyProfileManager?

            let completion: (AdaptyResult<AdaptyPaywall>) -> Void = { result in
                _ = result.do {
                    $0.sendImageUrlsToObserver()
                }
                completion(result)
            }
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
        _ locale: AdaptyLocale,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        let profileId = profileStorage.profileId
        httpFallbackSession.performFetchFallbackPaywallVariationsRequest(
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
    func getPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale,
        withFetchPolicy fetchPolicy: AdaptyPaywall.FetchPolicy,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        if let cached = paywallsCache.getPaywallByLocale(locale, orDefaultLocale: true, withPlacementId: placementId),
           fetchPolicy.canReturn(cached) {
            completion(.success(cached.value))
            getPaywall(placementId, locale) { _ in }
        } else {
            getPaywall(placementId, locale, completion)
        }
    }

    private func getPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        let segmentId = profile.value.segmentId
        let cached = paywallsCache.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId)?.value
        manager.httpSession.performFetchPaywallVariationsRequest(
            apiKeyPrefix: manager.apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            segmentId: segmentId,
            cached: cached,
            disableServerCache: profile.value.isTestUser
        ) { [weak self] (result: AdaptyResult<AdaptyPaywallChosen>) in

            guard let strongSelf = self, strongSelf.isActive else {
                completion(result.map {
                    Adapty.logIfNeed($0)
                    return $0.value
                })
                return
            }

            let result = result.map {
                let paywall = strongSelf.paywallsCache.savedPaywallChosen($0)
                Adapty.logIfNeed(paywall)
                return paywall.value
            }

            guard case let .failure(error) = result,
                  error.wrongProfileSegmentId
            else {
                completion(result)
                return
            }

            if segmentId != strongSelf.profile.value.segmentId {
                strongSelf.getPaywall(placementId, locale, completion)
                return
            }

            strongSelf.fetchSegmentId {
                if let error = $0 {
                    completion(.failure(error))
                    return
                }

                guard let strongSelf = self,
                      strongSelf.isActive,
                      segmentId != strongSelf.profile.value.segmentId
                else {
                    completion(result)
                    return
                }

                strongSelf.getPaywall(placementId, locale, completion)
            }
        }
    }

    private func fetchSegmentId(_ completion: @escaping AdaptyErrorCompletion) {
        manager.httpSession.performFetchProfileRequest(profileId: profileId, responseHash: profile.hash) { [weak self] result in
            completion(result
                .do {
                    self?.saveResponse($0.flatValue())
                }
                .error
            )
        }
    }

    func getFallbackPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        let cached = paywallsCache.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId)?.value
        manager.httpFallbackSession.performFetchFallbackPaywallVariationsRequest(
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

extension AdaptyError {
    var canUseFallbackServer: Bool {
        if let error = wrapped as? InternalAdaptyError {
            if case .fetchTimeoutError = error { return true }
        } else if let error = wrapped as? HTTPError {
            return Backend.canUseFallbackServer(error)
        }
        return false
    }

    var wrongProfileSegmentId: Bool {
        guard let error = wrapped as? HTTPError else { return false }
        return Backend.wrongProfileSegmentId(error)
    }
}

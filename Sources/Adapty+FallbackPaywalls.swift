//
//  Adapty+FallbackPaywalls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension Adapty.Configuration {
    static var fallbackPaywalls: FallbackPaywalls?
}

extension Adapty {
    /// To set fallback paywalls, use this method. You should pass exactly the same payload you're getting from Adapty backend. You can copy it from Adapty Dashboard.
    ///
    /// Adapty allows you to provide fallback paywalls that will be used when a user opens the app for the first time and there's no internet connection. Or in the rare case when Adapty backend is down and there's no cache on the device.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#fallback-paywalls)
    ///
    /// - Parameters:
    ///   - paywalls: a JSON representation of your paywalls/products list in the exact same format as provided by Adapty backend.
    ///   - completion: Result callback.
    public static func setFallbackPaywalls(_ paywalls: Data, _ completion: AdaptyErrorCompletion? = nil) {
        async(completion, logName: "set_fallback_paywalls") { completion in
            do {
                let fallbackPaywalls = try FallbackPaywalls(from: paywalls)
                let hasErrorVersion: Bool
                if fallbackPaywalls.formatVersion < FallbackPaywalls.currentFormatVersion {
                    hasErrorVersion = true
                    Log.error("The fallback paywalls version is not correct. Download a new one from the Adapty Dashboard.")
                } else if fallbackPaywalls.formatVersion > FallbackPaywalls.currentFormatVersion {
                    hasErrorVersion = true
                    Log.error("The fallback paywalls version is not correct. Please update the AdaptySDK.")
                } else {
                    hasErrorVersion = false
                }
                if hasErrorVersion {
                    Adapty.logSystemEvent(AdaptyInternalEventParameters(eventName: "fallback_wrong_version", params: [
                        "in_version": .value(fallbackPaywalls.formatVersion),
                        "expected_version": .value(FallbackPaywalls.currentFormatVersion),
                    ]))
                }
                Configuration.fallbackPaywalls = fallbackPaywalls
            } catch {
                completion(.decodingFallback(error))
                return
            }
            completion(nil)
        }
    }
}

extension PaywallsCache {
    func getPaywallWithFallback(byPlacementId placementId: String, locale: AdaptyLocale) -> AdaptyPaywall? {
        if let cache = getPaywallByLocale(locale, orDefaultLocale: true, withPlacementId: placementId)?.value,
           cache.version >= Adapty.Configuration.fallbackPaywalls?.getPaywallVersion(byPlacmentId: placementId) ?? 0 {
            return cache
        }

        guard let chosen = Adapty.Configuration.fallbackPaywalls?.getPaywall(byPlacmentId: placementId, profileId: profileId)
        else {
            return nil
        }
        Adapty.logIfNeed(chosen)
        Log.verbose("PaywallsCache: return from fallback paywall (placementId: \(placementId))")
        return chosen.value
    }
}

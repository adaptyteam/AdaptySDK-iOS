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
    ///   - fileURL:
    ///   - completion: Result callback.
    public static func setFallbackPaywalls(fileURL url: URL, _ completion: AdaptyErrorCompletion? = nil) {
        async(completion, logName: "set_fallback_paywalls") { completion in
            do {
                Configuration.fallbackPaywalls = try FallbackPaywalls(fileURL: url)
            } catch let error as AdaptyError {
                completion(error)
                return
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

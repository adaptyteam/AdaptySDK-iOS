//
//  Adapty+FallbackPaywalls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension Adapty {
    static var fallbackPaywalls: FallbackPaywalls?

    /// To set fallback paywalls, use this method. You should pass exactly the same payload you're getting from Adapty backend. You can copy it from Adapty Dashboard.
    ///
    /// Adapty allows you to provide fallback paywalls that will be used when a user opens the app for the first time and there's no internet connection. Or in the rare case when Adapty backend is down and there's no cache on the device.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#fallback-paywalls)
    ///
    /// - Parameters:
    ///   - fileURL:
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func setFallbackPaywalls(fileURL url: URL) async throws {
        try await withOptioanalSDK(methodName: .setFallbackPaywalls) { @AdaptyActor _ in
            do {
                Adapty.fallbackPaywalls = try FallbackPaywalls(fileURL: url)
            } catch {
                throw error.asAdaptyError ?? .decodingFallbackFailed(unknownError: error)
            }
        }
    }
}

private let log = Log.Category(name: "PaywallsCache")

extension PaywallsCache {
    // 2
    func getPaywallWithFallback(byPlacementId placementId: String, locale: AdaptyLocale) -> AdaptyPaywall? {
        let cache = getPaywallByLocale(locale, orDefaultLocale: true, withPlacementId: placementId)?.value

        guard let fallback = Adapty.fallbackPaywalls,
              fallback.contains(placementId: placementId) ?? true
        else {
            return cache
        }

        if let cache, cache.version >= fallback.version {
            return cache
        }

        guard let chosen = fallback.getPaywall(byPlacementId: placementId, profileId: profileId)
        else {
            return cache
        }

        Adapty.trackEventIfNeed(chosen)
        log.verbose("PaywallsCache: return from fallback paywall (placementId: \(placementId))")
        return chosen.value
    }
}



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
    /// Read more on the [Adapty Documentation](https://adapty.io/docs/ios-use-fallback-paywalls)
    ///
    /// - Parameters:
    ///   - fileURL:
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func setFallbackPaywalls(fileURL url: URL) async throws {
        try await withoutSDK(
            methodName: .setFallbackPaywalls
        ) { @AdaptyActor in
            do {
                Adapty.fallbackPaywalls = try FallbackPaywalls(fileURL: url)
            } catch {
                throw error.asAdaptyError ?? .decodingFallbackFailed(unknownError: error)
            }
        }
    }
}

private let log = Log.fallbackPaywalls

extension PaywallsStorage {
    private func getPaywall(byPlacementId placementId: String, withVariationId variationId: String?, profileId: String, locale: AdaptyLocale) -> AdaptyPaywallChosen? {
        getPaywallByLocale(locale, orDefaultLocale: true, withPlacementId: placementId, withVariationId: variationId).map {
            AdaptyPaywallChosen.restore($0.value)
        }
    }

    func getPaywallWithFallback(byPlacementId placementId: String, withVariationId variationId: String?, profileId: String, locale: AdaptyLocale) -> AdaptyPaywallChosen? {
        let cachedA = variationId == nil ? nil
            : getPaywall(byPlacementId: placementId, withVariationId: variationId, profileId: profileId, locale: locale)

        let cachedB = cachedA != nil ? nil
            : getPaywall(byPlacementId: placementId, withVariationId: nil, profileId: profileId, locale: locale)

        let cached = cachedA ?? cachedB

        guard let file = Adapty.fallbackPaywalls, file.contains(placementId: placementId) ?? true
        else {
            guard let cached else { return nil }
            Log.crossAB.verbose("return cached paywall (placementId: \(placementId), variationId: \(cached.paywall.variationId), version: \(cached.paywall.version)")
            return cached
        }

        switch (cachedA, cachedB) {
        case (.some(let cached), _):
            if cached.paywall.version < file.version,
               let fallback = file.getPaywall(byPlacementId: placementId, withVariationId: variationId, profileId: profileId)
            {
                Log.crossAB.verbose("return from fallback paywall (placementId: \(placementId), variationId: \(fallback.paywall.variationId), version: \(fallback.paywall.version))")
                return fallback
            } else {
                Log.crossAB.verbose("return cached paywall (placementId: \(placementId), variationId: \(cached.paywall.variationId), version: \(cached.paywall.version)")
                return cached
            }

        case (_, .some(let cached)):

            let fallbackA = variationId == nil ? nil :
                file.getPaywall(byPlacementId: placementId, withVariationId: variationId, profileId: profileId)

            let fallbackB = (fallbackA != nil || cached.paywall.version >= file.version) ? nil
                : file.getPaywall(byPlacementId: placementId, withVariationId: nil, profileId: profileId)

            if let fallback = fallbackA ?? fallbackB {
                Log.crossAB.verbose("return from fallback paywall (placementId: \(placementId), variationId: \(fallback.paywall.variationId), version: \(fallback.paywall.version)) no-cashe")

                return fallback
            } else {
                Log.crossAB.verbose("return cached paywall (placementId: \(placementId), variationId: \(cached.paywall.variationId), version: \(cached.paywall.version)")
                return cached
            }

        default:

            let fallback =
                if let variationId {
                    file.getPaywall(byPlacementId: placementId, withVariationId: variationId, profileId: profileId)
                        ?? file.getPaywall(byPlacementId: placementId, withVariationId: nil, profileId: profileId)
                } else {
                    file.getPaywall(byPlacementId: placementId, withVariationId: nil, profileId: profileId)
                }

            guard let fallback else { return nil }

            Log.crossAB.verbose("return from fallback paywall (placementId: \(placementId), variationId: \(fallback.paywall.variationId), version: \(fallback.paywall.version)) no-cashe")

            return fallback
        }
    }
}

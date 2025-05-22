//
//  Adapty+FallbackFile.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension Adapty {
    static var fallbackPlacements: FallbackPlacements?

    /// To set fallback paywalls, use this method. You should pass exactly the same payload you're getting from Adapty backend. You can copy it from Adapty Dashboard.
    ///
    /// Adapty allows you to provide fallback paywalls that will be used when a user opens the app for the first time and there's no internet connection. Or in the rare case when Adapty backend is down and there's no cache on the device.
    ///
    /// Read more on the [Adapty Documentation](https://adapty.io/docs/ios-use-fallback-paywalls)
    ///
    /// - Parameters:
    ///   - fileURL:
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func setFallback(fileURL url: URL) async throws {
        try await withoutSDK(
            methodName: .setFallback
        ) { @AdaptyActor in
            do {
                Adapty.fallbackPlacements = try FallbackPlacements(fileURL: url)
            } catch {
                throw error.asAdaptyError ?? .decodingFallbackFailed(unknownError: error)
            }
        }
    }
}

private let log = Log.fallbackPlacements

extension PlacementStorage {
    private func getPlacement<Content: AdaptyPlacementContent>(byPlacementId placementId: String, withVariationId variationId: String?, profileId: String, locale: AdaptyLocale) -> AdaptyPlacementChosen<Content>? {
        getPlacementByLocale(locale, orDefaultLocale: true, withPlacementId: placementId, withVariationId: variationId).map {
            AdaptyPlacementChosen.restore($0.value)
        }
    }

    func getPlacementWithFallback<Content: AdaptyPlacementContent>(byPlacementId placementId: String, withVariationId variationId: String?, profileId: String, locale: AdaptyLocale) -> AdaptyPlacementChosen<Content>? {
        let cachedA: AdaptyPlacementChosen<Content>? = variationId == nil ? nil
            : getPlacement(byPlacementId: placementId, withVariationId: variationId, profileId: profileId, locale: locale)

        let cachedB: AdaptyPlacementChosen<Content>? = cachedA != nil ? nil
            : getPlacement(byPlacementId: placementId, withVariationId: nil, profileId: profileId, locale: locale)

        let cached = cachedA ?? cachedB

        guard let fallbackFile = Adapty.fallbackPlacements, fallbackFile.contains(placementId: placementId) ?? true
        else {
            guard let cached else { return nil }
            Log.crossAB.verbose("return cached placement content (placementId: \(placementId), variationId: \(cached.content.variationId), version: \(cached.content.placement.version) no-fallback")
            return cached
        }

        switch (cachedA, cachedB) {
        case (.some(let cached), _):
            if cached.content.placement.version < fallbackFile.version,
               let fallbacked: AdaptyPlacementChosen<Content> = fallbackFile.getPlacement(byPlacementId: placementId, withVariationId: variationId, profileId: profileId)
            {
                Log.crossAB.verbose("return from fallback placement content (placementId: \(placementId), variationId: \(fallbacked.content.variationId), version: \(fallbacked.content.placement.version)) same-variation")
                return fallbacked
            } else {
                Log.crossAB.verbose("return cached placement content (placementId: \(placementId), variationId: \(cached.content.variationId), version: \(cached.content.placement.version) same-variation")
                return cached
            }

        case (_, .some(let cached)):

            let fallBackedA: AdaptyPlacementChosen<Content>? = variationId == nil ? nil :
                fallbackFile.getPlacement(byPlacementId: placementId, withVariationId: variationId, profileId: profileId)

            let fallBackedB: AdaptyPlacementChosen<Content>? = (fallBackedA != nil || cached.content.placement.version >= fallbackFile.version) ? nil
                : fallbackFile.getPlacement(byPlacementId: placementId, withVariationId: nil, profileId: profileId)

            if let fallBacked = fallBackedA ?? fallBackedB {
                Log.crossAB.verbose("return from fallback placement content (placementId: \(placementId), variationId: \(fallBacked.content.variationId), version: \(fallBacked.content.placement.version))")

                return fallBacked
            } else {
                Log.crossAB.verbose("return cached placement content (placementId: \(placementId), variationId: \(cached.content.variationId), version: \(cached.content.placement.version)")
                return cached
            }

        default:

            let fallBacked: AdaptyPlacementChosen<Content>? =
                if let variationId {
                    fallbackFile.getPlacement(byPlacementId: placementId, withVariationId: variationId, profileId: profileId)
                        ?? fallbackFile.getPlacement(byPlacementId: placementId, withVariationId: nil, profileId: profileId)
                } else {
                    fallbackFile.getPlacement(byPlacementId: placementId, withVariationId: nil, profileId: profileId)
                }

            guard let fallBacked else { return nil }

            Log.crossAB.verbose("return from fallback plqcement content (placementId: \(placementId), variationId: \(fallBacked.content.variationId), version: \(fallBacked.content.placement.version)) no-cache")

            return fallBacked
        }
    }
}

//
//  PlacementContent+Cache.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.05.2026.
//

import Foundation

extension Cache {
    @inlinable
    static func read<Content: PlacementContent>(
        placementId: String,
        locale: AdaptyLocale?,
        fetchPolicy: AdaptyPlacementFetchPolicy,
        for userId: AdaptyUserId
    ) async -> AdaptyPlacement.Draw<Content>? {
        let crossPlacementState = CrossPlacementStorage.state(for: userId)
        if let variationId = crossPlacementState?.variationId(placementId: placementId) {
            return await Cache.readPlacement(
                placementId: placementId,
                variationId: variationId,
                locale: locale,
                for: userId
            )
        } else {
            return await Cache.readPlacementVariations(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy,
                for: userId
            )
        }
    }

    private static func readPlacementVariations<Content: PlacementContent>(
        placementId: String,
        locale: AdaptyLocale?,
        fetchPolicy: AdaptyPlacementFetchPolicy,
        for userId: AdaptyUserId
    ) async -> AdaptyPlacement.Draw<Content>? {
        let jsonDecoder = JSONDecoder()
        Backend.configure(jsonDecoder: jsonDecoder)

        return Cache.read(
            Content.cacheKey(placementId: placementId, for: userId),
            accept: Content.shouldUseExisting(with: fetchPolicy, locale: locale),
            decode: { meta, data in
                do {
                    return try jsonDecoder.decodePlacementVariations(
                        withUserId: userId,
                        withRequestLocale: locale,
                        crossPlacementEligible: meta.eligibleCrossABtest,
                        from: data
                    )
                } catch {
                    if case .notFoundVariationId = error as? PlacementDecodingError {
                        throw Cache.DecodeRejected(underlying: error)
                    }
                    throw error
                }
            }
        )
    }

    private static func readPlacement<Content: PlacementContent>(
        placementId: String,
        variationId: String,
        locale: AdaptyLocale?,
        for userId: AdaptyUserId
    ) async -> AdaptyPlacement.Draw<Content>? {
        let jsonDecoder = JSONDecoder()
        Backend.configure(jsonDecoder: jsonDecoder)

        let cached: AdaptyPlacement.Draw<Content>? = Cache.read(
            Content.cacheKey(variationId: variationId),
            accept: Content.shouldUseExisting(with: .returnCacheDataElseLoad, locale: locale),
            decode: { _, data in
                try jsonDecoder.decodePlacement(
                    withUserId: userId,
                    withRequestLocale: locale,
                    from: data
                )
            }
        )

        guard cached == nil else { return cached }

        return Cache.read(
            Content.cacheKey(placementId: placementId, for: userId),
            accept: Content.shouldUseExisting(with: .returnCacheDataElseLoad, locale: locale),
            decode: { _, data in
                do {
                    return try jsonDecoder.decodePlacementVariations(
                        variationId: variationId,
                        withUserId: userId,
                        withRequestLocale: locale,
                        from: data
                    )
                } catch let error as PlacementDecodingError where error == .notFoundVariationId {
                    throw Cache.DecodeRejected(underlying: error)
                }
            }
        )
    }
}

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
        _ type: Content.Type,
        placementId: String,
        locale: AdaptyLocale?,
        fetchPolicy: AdaptyPlacementFetchPolicy,
        for userId: AdaptyUserId,
        fallbackFile: FallbackPlacements? = nil
    ) async -> AdaptyPlacement.Draw<Content>? {
        let crossPlacementState = CrossPlacementStorage.state(for: userId)
        if let variationId = crossPlacementState?.variationId(placementId: placementId) {
            return Cache.readPlacement(
                type,
                placementId: placementId,
                variationId: variationId,
                locale: locale,
                for: userId,
                fallbackFile: fallbackFile
            )
        } else {
            return Cache.readPlacementVariations(
                type,
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy,
                for: userId,
                fallbackFile: fallbackFile
            )
        }
    }

    private static func readPlacementVariations<Content: PlacementContent>(
        _: Content.Type,
        placementId: String,
        locale: AdaptyLocale?,
        fetchPolicy: AdaptyPlacementFetchPolicy,
        for userId: AdaptyUserId,
        fallbackFile: FallbackPlacements?
    ) -> AdaptyPlacement.Draw<Content>? {

        let fallbackFileVersion: Int? =
        if let fallbackFile, fallbackFile.contains(placementId: placementId, variationId: nil) {
                fallbackFile.version
            } else {
                nil
            }

        let jsonDecoder = JSONDecoder()
        Backend.configure(jsonDecoder: jsonDecoder)

        let draw: AdaptyPlacement.Draw<Content>? = Cache.read(
            Content.cacheKey(placementId: placementId, for: userId),
            accept: Content.shouldUseExisting(with: fetchPolicy, locale: locale),
            decode: { meta, data in
                do {
                    return try jsonDecoder.decodePlacementVariations(
                        crossPlacementEligible: meta.eligibleCrossABtest,
                        variationId: nil,
                        withUserId: userId,
                        withRequestLocale: locale,
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

        guard let draw else { return nil }

        if !CrossPlacementStorage.set(draw: draw) {
            Log.verboseCrosABDrawResult(
                draw: draw,
                variationId: nil,
                crossPlacmentState: CrossPlacementStorage.state(for: userId)
            )
        }

        return draw
    }

    private static func readPlacement<Content: PlacementContent>(
        _: Content.Type,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale?,
        for userId: AdaptyUserId,
        fallbackFile: FallbackPlacements?
    ) -> AdaptyPlacement.Draw<Content>? {

        let fallbackFileVersion: Int? =
        if let fallbackFile, fallbackFile.contains(placementId: placementId, variationId: variationId) {
                fallbackFile.version
            } else {
                nil
            }

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
            decode: { meta, data in
                do {
                    return try jsonDecoder.decodePlacementVariations(
                        crossPlacementEligible: meta.eligibleCrossABtest,
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


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
        _ type: Content.Type,
        placementId: String,
        locale: AdaptyLocale?,
        fetchPolicy: AdaptyPlacementFetchPolicy,
        for userId: AdaptyUserId,
        fallbackFile: FallbackPlacements?
    ) -> AdaptyPlacement.Draw<Content>? {
        let jsonDecoder = JSONDecoder()
        Backend.configure(jsonDecoder: jsonDecoder)

        let cachedDraw: AdaptyPlacement.Draw<Content>? = Cache.read(
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

        let draw = Cache.readFallbackPlacement(
            type,
            than: cachedDraw,
            placementId: placementId,
            withVariationId: nil,
            requestLocale: locale,
            for: userId,
            fallbackFile: fallbackFile
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
        _ type: Content.Type,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale?,
        for userId: AdaptyUserId,
        fallbackFile: FallbackPlacements?
    ) -> AdaptyPlacement.Draw<Content>? {
        let jsonDecoder = JSONDecoder()
        Backend.configure(jsonDecoder: jsonDecoder)

        var draw: AdaptyPlacement.Draw<Content>?

        draw = Cache.read(
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

        if draw == nil {
            draw = Cache.read(
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

        return Cache.readFallbackPlacement(
            type,
            than: draw,
            placementId: placementId,
            withVariationId: variationId,
            requestLocale: locale,
            for: userId,
            fallbackFile: fallbackFile
        )
    }

    private static func readFallbackPlacement<Content: PlacementContent>(
        _ type: Content.Type,
        than cachedDraw: AdaptyPlacement.Draw<Content>?,
        placementId: String,
        withVariationId variationId: String?,
        requestLocale: AdaptyLocale?,
        for userId: AdaptyUserId,
        fallbackFile: FallbackPlacements?
    ) -> AdaptyPlacement.Draw<Content>? {
        guard let fallbackFile else { return cachedDraw }

        if let cachedDraw,
           cachedDraw.content.placement.version >= fallbackFile.version
        {
            return cachedDraw
        }

        return (try? fallbackFile.getPlacement(
            type,
            byPlacementId: placementId,
            withVariationId: variationId,
            userId: userId,
            requestLocale: requestLocale
        )) ?? cachedDraw
    }
}

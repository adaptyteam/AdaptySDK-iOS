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

        var notFoundVariationId = false
        let cached: AdaptyPlacement.Draw<Content>? = Cache.read(
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
                        notFoundVariationId = true
                        throw Cache.DecodeRejected(underlying: error)
                    }
                    throw error
                }
            }
        )

        guard
            cached == nil,
            notFoundVariationId,
            let variationId = CrossPlacementStorage.state(for: userId)?.variationId(placementId: placementId)
        else { return cached }

        return Cache.read(
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

extension JSONDecoder {
    func decodePlacement<Content: PlacementContent>(
        withUserId userId: AdaptyUserId,
        withRequestLocale requestLocale: AdaptyLocale? = nil,
        from body: Data
    ) throws -> AdaptyPlacement.Draw<Content> {
        let placement = try decode(
            Backend.Response.Meta<AdaptyPlacement>.self,
            from: body
        ).value

        let configuration = AdaptyPlacement.DecodingConfiguration(
            userId: nil,
            placement: placement,
            requestLocale: requestLocale,
            variationId: nil
        )

        let content = try decode(
            Backend.Response.Data<Content>.self,
            from: body,
            with: configuration
        ).value

        let variation = try decode(
            Backend.Response.Data<AdaptyPlacement.Variation>.self,
            from: body
        ).value

        return AdaptyPlacement.Draw<Content>(
            date: Date(),
            userId: userId,
            content: content,
            placementAudienceVersionId: placement.audienceVersionId,
            variationIdByPlacements: variation.variationIdByPlacements
        )
    }

    fileprivate func decodePlacementVariations<Content: PlacementContent>(
        variationId: String,
        withUserId userId: AdaptyUserId,
        withRequestLocale requestLocale: AdaptyLocale? = nil,
        from body: Data
    ) throws -> AdaptyPlacement.Draw<Content> {
        let placement = try decode(
            Backend.Response.Meta<AdaptyPlacement>.self,
            from: body
        ).value

        let configuration = AdaptyPlacement.DecodingConfiguration(
            userId: userId,
            placement: placement,
            requestLocale: requestLocale,
            variationId: variationId
        )

        return try decode(
            Backend.Response.Data<AdaptyPlacement.Draw<Content>>.self,
            from: body,
            with: configuration
        ).value
    }

    @StorageActor
    func decodePlacementVariations<Content: PlacementContent>(
        withUserId userId: AdaptyUserId,
        withRequestLocale requestLocale: AdaptyLocale? = nil,
        crossPlacementEligible: Bool,
        from body: Data
    ) throws -> AdaptyPlacement.Draw<Content> {
        let placement = try decode(
            Backend.Response.Meta<AdaptyPlacement>.self,
            from: body
        ).value

        var configuration = AdaptyPlacement.DecodingConfiguration(
            userId: userId,
            placement: placement,
            requestLocale: requestLocale,
            variationId: nil
        )

        let crossPlacmentState = CrossPlacementStorage.state(for: userId)

        if let variationId = crossPlacmentState?.variationId(placementId: placement.id) {
            configuration.variationId = variationId
        }

        let draw: AdaptyPlacement.Draw<Content>

        do {
            draw = try decode(
                Backend.Response.Data<AdaptyPlacement.Draw<Content>>.self,
                from: body,
                with: configuration
            ).value
        } catch {
            if let variationId = configuration.variationId {
                Log.crossAB.verbose("FAIL PlacementId = \(placement.id), with variationId = \(variationId),  current state = \(crossPlacmentState, default: "DISABLED"),  error: \(error)")
            } else {
                Log.crossAB.verbose("FAIL PlacementId = \(placement.id),  current state = \(crossPlacmentState, default: "DISABLED"),  error: \(error)")
            }

            throw error
        }

        guard let crossPlacmentState else {
            Log.crossAB.verbose("PlacementId = \(placement.id), DISABLED CROSS-AB -> variationId = \(draw.content.variationId) DRAW")
            return draw
        }

        if crossPlacmentState.canParticipateInABTest {
            if draw.participatesInCrossPlacementABTest, crossPlacementEligible {
                Log.crossAB.verbose("PlacementId = \(placement.id), BEGIN CROSS-AB    -> variationId = \(draw.content.variationId) DRAW, new state = \(draw.variationIdByPlacements)")
                CrossPlacementStorage.set(draw: draw)
            } else {
                Log.crossAB.verbose("PlacementId = \(placement.id), EMPTY CROSS-AB    -> variationId = \(draw.content.variationId) DRAW (ab-test)")
            }
        } else {
            if configuration.variationId == draw.content.variationId {
                Log.crossAB.verbose("PlacementId = \(placement.id), CONTINUE CROSS-AB -> variationId = \(draw.content.variationId), current state = \(crossPlacmentState)")
            } else if draw.participatesInCrossPlacementABTest, crossPlacementEligible {
                Log.crossAB.verbose("PlacementId = \(placement.id), OTHER CROSS-AB    -> variationId = \(draw.content.variationId) DRAW, other = \(crossPlacmentState), current state = \(draw.variationIdByPlacements)")
            } else {
                Log.crossAB.verbose("PlacementId = \(placement.id), OTHER AB-TEST     -> variationId = \(draw.content.variationId) DRAW, current state = \(crossPlacmentState)")
            }
        }

        return draw
    }
}

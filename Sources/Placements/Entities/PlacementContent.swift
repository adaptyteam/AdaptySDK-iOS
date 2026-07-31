//
//  PlacementContent.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2025.
//

import Foundation

protocol PlacementContent: Sendable, Encodable, DecodableWithConfiguration where DecodingConfiguration == AdaptyPlacement.DecodingConfiguration {
    var placement: AdaptyPlacement { get }
    var id: String { get }
    var variationId: String { get }
    var name: String { get }

    static func cacheKey(variationId: String) -> Cache.ItemKey
    static func cacheKey(placementId: String, for userId: AdaptyUserId) -> Cache.ItemKey

    static func shouldUseNew(new: Cache.Meta, existing: Cache.Meta) -> Bool
    static func shouldUseExisting(with fetchPolicy: AdaptyPlacementFetchPolicy, locale: AdaptyLocale?) -> @Sendable (Cache.Meta) -> Bool
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

        let content = try decode(
            Backend.Response.Data<Content>.self,
            from: body,
            with: .init(
                placement: placement,
                onboardingRequestLocale: requestLocale
            )
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

    func decodePlacementVariations<Content: PlacementContent>(
        variationId: String,
        withUserId userId: AdaptyUserId,
        withRequestLocale requestLocale: AdaptyLocale? = nil,
        from body: Data
    ) throws -> AdaptyPlacement.Draw<Content> {
        let placement = try decode(
            Backend.Response.Meta<AdaptyPlacement>.self,
            from: body
        ).value

        return try decode(
            Backend.Response.Data<AdaptyPlacement.Draw<Content>>.self,
            from: body,
            with: .init(
                userId: userId,
                placement: placement,
                onboardingRequestLocale: requestLocale,
                variationId: variationId
            )
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

        let crossPlacmentState = CrossPlacementStorage.state(for: userId)
        let variationId = crossPlacmentState?.variationId(placementId: placement.id)
        let draw: AdaptyPlacement.Draw<Content>

        do {
            draw = try decode(
                Backend.Response.Data<AdaptyPlacement.Draw<Content>>.self,
                from: body,
                with: .init(
                    userId: userId,
                    placement: placement,
                    onboardingRequestLocale: requestLocale,
                    variationId: variationId
                )
            ).value
        } catch {
            if let variationId {
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
            if let variationId, variationId == draw.content.variationId {
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


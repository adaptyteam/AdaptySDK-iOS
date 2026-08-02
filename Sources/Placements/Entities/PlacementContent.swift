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
        withRequestLocale onboardingRequestLocale: AdaptyLocale? = nil,
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
                onboardingRequestLocale: onboardingRequestLocale
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
        crossPlacementEligible: Bool,
        variationId: String?,
        withUserId userId: AdaptyUserId,
        withRequestLocale onboardingRequestLocale: AdaptyLocale? = nil,
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
                crossPlacementEligible: crossPlacementEligible,
                onboardingRequestLocale: onboardingRequestLocale,
                variationId: variationId
            )
        ).value
    }
}

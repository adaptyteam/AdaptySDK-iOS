//
//  AdaptyPlacementChosen+Decoder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.11.2025.
//

import Foundation

extension AdaptyPlacementChosen {
    typealias VariationIdResolver = @Sendable (_ placementId: String, AdaptyPlacement.Draw<Content>) async throws -> String

    @inlinable
    static func createDecoder(
        withUserId userId: AdaptyUserId,
        withPlacementId placementId: String,
        withRequestLocale requestLocale: AdaptyLocale? = nil,
        withCached cached: Content?,
        variationIdResolver: VariationIdResolver?
    ) -> HTTPDecoder<AdaptyPlacementChosen> {
        return decoder

        @Sendable
        func decoder(
            _ response: HTTPDataResponse,
            _ configuration: HTTPCodableConfiguration?,
            _: HTTPRequest
        ) async throws -> HTTPResponse<AdaptyPlacementChosen> {
            let body = response.body ?? Data()
            let jsonDecoder = JSONDecoder()
            configuration?.configure(jsonDecoder: jsonDecoder)

            let placement = try jsonDecoder.decode(
                Backend.Response.Meta<AdaptyPlacement>.self,
                from: body
            ).value

            if let cached, cached.placement.isNewerThan(placement) {
                return response.replaceBody(AdaptyPlacementChosen.restore(cached))
            }

            var configuration = AdaptyPlacement.DecodingConfiguration(
                userId: userId,
                placement: placement,
                requestLocale: requestLocale,
                variationId: nil
            )

            let draw = try jsonDecoder.decode(
                Backend.Response.Data<AdaptyPlacement.Draw<Content>>.self,
                from: body,
                with: configuration
            ).value

            guard let variationId = try await variationIdResolver?(placementId, draw),
                  variationId != draw.content.variationId
            else {
                if variationIdResolver == nil {
                    Log.crossAB.verbose("AB-test placementId = \(placementId), variationId = \(draw.content.variationId) DRAW")
                }
                return response.replaceBody(AdaptyPlacementChosen.draw(draw))
            }

            configuration.variationId = variationId

            let variation = try jsonDecoder.decode(
                Backend.Response.Data<AdaptyPlacement.Draw<Content>>.self,
                from: body,
                with: configuration
            ).value

            return response.replaceBody(AdaptyPlacementChosen.draw(variation))
        }
    }

    @inlinable
    static func createDecoder(
        withUserId userId: AdaptyUserId,
        withRequestLocale requestLocale: AdaptyLocale? = nil,
        withCached cached: Content?
    ) -> HTTPDecoder<AdaptyPlacementChosen> {
        return decoder

        @Sendable
        func decoder(
            _ response: HTTPDataResponse,
            _ configuration: HTTPCodableConfiguration?,
            _: HTTPRequest
        ) async throws -> HTTPResponse<AdaptyPlacementChosen> {
            let body = response.body ?? Data()
            let jsonDecoder = JSONDecoder()
            configuration?.configure(jsonDecoder: jsonDecoder)

            let placement = try jsonDecoder.decode(
                Backend.Response.Meta<AdaptyPlacement>.self,
                from: body
            ).value

            if let cached, cached.placement.isNewerThan(placement) {
                return response.replaceBody(AdaptyPlacementChosen.restore(cached))
            }

            let variation = try jsonDecoder.decode(
                Backend.Response.Data<AdaptyPlacement.Variation>.self,
                from: body
            ).value

            let configuration = AdaptyPlacement.DecodingConfiguration(
                userId: userId,
                placement: placement,
                requestLocale: requestLocale,
                variationId: nil
            )

            let content = try jsonDecoder.decode(
                Backend.Response.Data<Content>.self,
                from: body,
                with: configuration
            ).value

            let draw = AdaptyPlacement.Draw<Content>(
                userId: userId,
                content: content,
                placementAudienceVersionId: placement.audienceVersionId,
                variationIdByPlacements: variation.variationIdByPlacements
            )

            return response.replaceBody(AdaptyPlacementChosen.draw(draw))
        }
    }
}


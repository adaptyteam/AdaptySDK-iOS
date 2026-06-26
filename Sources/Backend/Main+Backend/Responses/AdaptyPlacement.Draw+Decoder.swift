//
//  AdaptyPlacement.Draw+Decoder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.11.2025.
//

import Foundation

extension AdaptyPlacement.Draw {
    @inlinable
    static func placementVariationsDecoder(
        withUserId userId: AdaptyUserId,
        withPlacementId placementId: String,
        withRequestLocale requestLocale: AdaptyLocale?,
        crossPlacementEligible: Bool,
        segmentId: String? = nil
    ) -> HTTPDecoder<AdaptyPlacement.Draw<Content>> {
        return decoder

        @StorageActor
        func decoder(
            _ response: HTTPDataResponse,
            _ configuration: HTTPCodableConfiguration?,
            _: HTTPRequest
        ) async throws -> HTTPResponse<AdaptyPlacement.Draw<Content>> {
            let body = response.body ?? Data()
            let jsonDecoder = JSONDecoder()
            configuration?.configure(jsonDecoder: jsonDecoder)

            let draw: AdaptyPlacement.Draw<Content> = try Cache.writeOrRead(
                body,
                key: Content.cacheKey(placementId: placementId, for: userId),
                locale: requestLocale,
                eligibleCrossABtest: crossPlacementEligible,
                segmentId: segmentId,
                dataVersion: jsonDecoder.decodeAdaptyPlacementVersion(from: body),
                accept: Content.shouldUseNew,
                decode: { meta, data in
                    try jsonDecoder.decodePlacementVariations(
                        withUserId: userId,
                        withRequestLocale: requestLocale,
                        crossPlacementEligible: meta.eligibleCrossABtest,
                        from: data
                    )
                }
            )
            return response.replaceBody(draw)
        }
    }

    @inlinable
    static func placementDecoder(
        withUserId userId: AdaptyUserId,
        withVariationId variationId: String,
        withRequestLocale requestLocale: AdaptyLocale?
    ) -> HTTPDecoder<AdaptyPlacement.Draw<Content>> {
        return decoder

        @StorageActor
        func decoder(
            _ response: HTTPDataResponse,
            _ configuration: HTTPCodableConfiguration?,
            _: HTTPRequest
        ) async throws -> HTTPResponse<AdaptyPlacement.Draw<Content>> {
            let body = response.body ?? Data()
            let jsonDecoder = JSONDecoder()
            configuration?.configure(jsonDecoder: jsonDecoder)

            let draw: AdaptyPlacement.Draw<Content> = try Cache.writeOrRead(
                body,
                key: Content.cacheKey(variationId: variationId),
                locale: requestLocale,
                dataVersion: jsonDecoder.decodeAdaptyPlacementVersion(from: body),
                accept: Content.shouldUseNew,
                decode: { _, data in
                    try jsonDecoder.decodePlacement(
                        withUserId: userId,
                        withRequestLocale: requestLocale,
                        from: data
                    )
                }
            )

            return response.replaceBody(draw)
        }
    }

    @inlinable
    static func persistPlacementVariations(
        withUserId userId: AdaptyUserId,
        withPlacementId placementId: String,
        withRequestLocale requestLocale: AdaptyLocale?,
        crossPlacementEligible: Bool,
        segmentId: String? = nil
    ) -> HTTPDecoder<Data?> {
        return decoder

        @StorageActor
        func decoder(
            _ response: HTTPDataResponse,
            _ configuration: HTTPCodableConfiguration?,
            _: HTTPRequest
        ) async throws -> HTTPDataResponse {
            let body = response.body ?? Data()
            let jsonDecoder = JSONDecoder()
            configuration?.configure(jsonDecoder: jsonDecoder)

            try Cache.write(
                body,
                key: Content.cacheKey(placementId: placementId, for: userId),
                locale: requestLocale,
                eligibleCrossABtest: crossPlacementEligible,
                segmentId: segmentId,
                dataVersion: jsonDecoder.decodeAdaptyPlacementVersion(from: body),
                accept: Content.shouldUseNew
            )
            return response
        }
    }

    @inlinable
    static func persistPlacement(
        withVariationId variationId: String,
        withRequestLocale requestLocale: AdaptyLocale?
    ) -> HTTPDecoder<Data?> {
        return decoder

        @StorageActor
        func decoder(
            _ response: HTTPDataResponse,
            _ configuration: HTTPCodableConfiguration?,
            _: HTTPRequest
        ) async throws -> HTTPDataResponse {
            let body = response.body ?? Data()
            let jsonDecoder = JSONDecoder()
            configuration?.configure(jsonDecoder: jsonDecoder)

            try Cache.write(
                body,
                key: Content.cacheKey(variationId: variationId),
                locale: requestLocale,
                dataVersion: jsonDecoder.decodeAdaptyPlacementVersion(from: body),
                accept: Content.shouldUseNew
            )
            return response
        }
    }
}

private extension JSONDecoder {
    func decodeAdaptyPlacementVersion(from body: Data) throws -> Int {
        struct Meta: Decodable {
            let version: Int

            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: AdaptyPlacement.CodingKeys.self)
                version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 0
            }
        }

        return try decode(
            Backend.Response.Meta<Meta>.self,
            from: body
        ).value.version
    }
}

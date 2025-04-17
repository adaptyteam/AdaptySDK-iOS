//
//  FetchPlacementRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

private struct FetchPlacementRequest: HTTPRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    init(
        endpoint: HTTPEndpoint,
        profileId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) {
        self.endpoint = endpoint

        headers = HTTPHeaders()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
            .setVisualBuilderVersion(AdaptyViewConfiguration.builderVersion)
            .setVisualBuilderConfigurationFormatVersion(AdaptyViewConfiguration.formatVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension AdaptyPlacementChosen {
    @inlinable
    static func decodePlacementResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?,
        withProfileId profileId: String,
        withCached cached: Content?
    ) async throws -> HTTPResponse<AdaptyPlacementChosen> {
        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)

        let placement = try jsonDecoder.decode(
            Backend.Response.Meta<AdaptyPlacement>.self,
            responseBody: response.body
        ).value

        if let cached, cached.placement.version > placement.version {
            return response.replaceBody(AdaptyPlacementChosen.restore(cached))
        }

        jsonDecoder.setPlacement(placement)

        let variation = try jsonDecoder.decode(
            Backend.Response.Data<AdaptyPlacement.Variation>.OptionalAttributes.self,
            responseBody: response.body
        ).value
        
        let content = try jsonDecoder.decode(
            Backend.Response.Data<Content>.OptionalAttributes.self,
            responseBody: response.body
        ).value

        let draw = AdaptyPlacement.Draw<Content>(
            profileId: profileId,
            content: content,
            placementAudienceVersionId: placement.placementAudienceVersionId, // TODO: extract from placement
            variationIdByPlacements: variation.variationIdByPlacements
        )

        return response.replaceBody(AdaptyPlacementChosen.draw(draw))
    }
}

extension Backend.MainExecutor {
    func fetchPlacement<Content: AdaptyPlacementContent>(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale,
        cached: Content?,
        disableServerCache: Bool
    ) async throws -> AdaptyPlacementChosen<Content> {
        let endpoint: HTTPEndpoint
        let requestName: APIRequestName
        let md5Hash: String

        if Content.self == AdaptyPaywall.self {
            md5Hash = "{\"builder_version\":\"\(AdaptyViewConfiguration.builderVersion)\",\"locale\":\"\(locale.id.lowercased())\",\"store\":\"app_store\"}".md5.hexString
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/\(variationId)/"
            )
            requestName = .fetchPaywall
        } else {
            md5Hash = "{\"locale\":\"\(locale.id.lowercased())\"}".md5.hexString
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(md5Hash)/\(variationId)/"
            )
            requestName = .fetchOnboarding
        }

        let request = FetchPlacementRequest(
            endpoint: endpoint,
            profileId: profileId,
            locale: locale,
            disableServerCache: disableServerCache
        )

        let configuration = session.configuration as? HTTPCodableConfiguration

        let response = try await perform(
            request,
            requestName: requestName,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "variation_id": variationId,
                "locale": locale,
                "builder_version": AdaptyViewConfiguration.builderVersion,
                "builder_config_format_version": AdaptyViewConfiguration.formatVersion,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        ) { @Sendable response in
            try await AdaptyPlacementChosen.decodePlacementResponse(
                response,
                withConfiguration: configuration,
                withProfileId: profileId,
                withCached: cached
            )
        }

        return response.body
    }
}

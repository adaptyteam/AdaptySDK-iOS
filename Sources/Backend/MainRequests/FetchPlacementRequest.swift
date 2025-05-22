//
//  FetchPlacementRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

private struct FetchPaywallRequest: HTTPRequest, BackendAPIRequestParameters {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    let logName = APIRequestName.fetchPaywall
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) {
        let md5Hash = "{\"builder_version\":\"\(AdaptyViewConfiguration.builderVersion)\",\"locale\":\"\(locale.id.lowercased())\",\"store\":\"app_store\"}".md5.hexString

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/\(variationId)/"
        )

        headers = HTTPHeaders()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
            .setPaywallBuilderVersion(AdaptyViewConfiguration.builderVersion)
            .setPaywallBuilderConfigurationFormatVersion(AdaptyViewConfiguration.formatVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        logParams = [
            "api_prefix": apiKeyPrefix,
            "placement_id": placementId,
            "variation_id": variationId,
            "locale": locale,
            "builder_version": AdaptyViewConfiguration.builderVersion,
            "builder_config_format_version": AdaptyViewConfiguration.formatVersion,
            "md5": md5Hash,
            "disable_server_cache": disableServerCache,
        ]
    }
}

private struct FetchOnboardingRequest: HTTPRequest, BackendAPIRequestParameters {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    let logName = APIRequestName.fetchOnboarding
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) {
        let md5Hash = "{\"locale\":\"\(locale.id.lowercased())\"}".md5.hexString

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(md5Hash)/\(variationId)/"
        )

        headers = HTTPHeaders()
            .setOnboardingLocale(locale)
            .setBackendProfileId(profileId)
            .setOnboardingUIVersion(AdaptyOnboarding.ViewConfiguration.uiVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        logParams = [
            "api_prefix": apiKeyPrefix,
            "placement_id": placementId,
            "variation_id": variationId,
            "locale": locale,
            "md5": md5Hash,
            "disable_server_cache": disableServerCache,
        ]
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
            Backend.Response.Data<AdaptyPlacement.Variation>.self,
            responseBody: response.body
        ).value

        let content = try jsonDecoder.decode(
            Backend.Response.Data<Content>.self,
            responseBody: response.body
        ).value

        let draw = AdaptyPlacement.Draw<Content>(
            profileId: profileId,
            content: content,
            placementAudienceVersionId: placement.audienceVersionId,
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
        let request: HTTPRequest & BackendAPIRequestParameters =
            if Content.self == AdaptyPaywall.self {
                FetchPaywallRequest(
                    apiKeyPrefix: apiKeyPrefix,
                    profileId: profileId,
                    placementId: placementId,
                    variationId: variationId,
                    locale: locale,
                    disableServerCache: disableServerCache
                )

            } else {
                FetchOnboardingRequest(
                    apiKeyPrefix: apiKeyPrefix,
                    profileId: profileId,
                    placementId: placementId,
                    variationId: variationId,
                    locale: locale,
                    disableServerCache: disableServerCache
                )
            }

        let configuration = session.configuration as? HTTPCodableConfiguration

        let response = try await perform(request) { @Sendable response in
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

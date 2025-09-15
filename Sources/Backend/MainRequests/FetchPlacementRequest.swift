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
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) {
        let md5Hash = "{\"builder_version\":\"\(Adapty.uiBuilderVersion)\",\"locale\":\"\(locale.id.lowercased())\",\"store\":\"app_store\"}".md5.hexString

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/\(variationId)/"
        )

        headers = HTTPHeaders()
            .setPaywallLocale(locale)
            .setUserProfileId(userId)
            .setPaywallBuilderVersion(Adapty.uiBuilderVersion)
            .setPaywallBuilderConfigurationFormatVersion(Adapty.uiSchemaVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        logParams = [
            "api_prefix": apiKeyPrefix,
            "placement_id": placementId,
            "variation_id": variationId,
            "locale": locale,
            "builder_version": Adapty.uiBuilderVersion,
            "builder_config_format_version": Adapty.uiSchemaVersion,
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
        userId: AdaptyUserId,
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
            .setUserProfileId(userId)
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
        withUserId userId: AdaptyUserId,
        withRequestLocale requestLocale: AdaptyLocale,
        withCached cached: Content?
    ) async throws -> HTTPResponse<AdaptyPlacementChosen> {
        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)

        let placement = try jsonDecoder.decode(
            Backend.Response.Meta<AdaptyPlacement>.self,
            responseBody: response.body
        ).value

        if let cached, cached.placement.isNewerThan(placement) {
            return response.replaceBody(AdaptyPlacementChosen.restore(cached))
        }

        jsonDecoder.userInfo.setPlacement(placement)
        jsonDecoder.userInfo.setRequestLocale(requestLocale)

        let variation = try jsonDecoder.decode(
            Backend.Response.Data<AdaptyPlacement.Variation>.self,
            responseBody: response.body
        ).value

        let content = try jsonDecoder.decode(
            Backend.Response.Data<Content>.self,
            responseBody: response.body
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

extension Backend.MainExecutor {
    func fetchPlacement<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale,
        cached: Content?,
        disableServerCache: Bool
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let request: HTTPRequest & BackendAPIRequestParameters =
            if Content.self == AdaptyPaywall.self {
                FetchPaywallRequest(
                    apiKeyPrefix: apiKeyPrefix,
                    userId: userId,
                    placementId: placementId,
                    variationId: variationId,
                    locale: locale,
                    disableServerCache: disableServerCache
                )

            } else {
                FetchOnboardingRequest(
                    apiKeyPrefix: apiKeyPrefix,
                    userId: userId,
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
                withUserId: userId,
                withRequestLocale: locale,
                withCached: cached
            )
        }

        return response.body
    }
}

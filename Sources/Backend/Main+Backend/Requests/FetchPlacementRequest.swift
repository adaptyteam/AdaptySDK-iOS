//
//  FetchPlacementRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

private struct FetchFlowRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    let requestName = BackendRequestName.fetchPaywall
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        disableServerCache: Bool
    ) {
        let md5Hash = "{\"builder_version\":\"\(Adapty.uiBuilderVersion)\",\"store\":\"app_store\"}".md5.hexString

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/flow/variations/\(placementId)/\(md5Hash)/\(variationId)/"
        )

        headers = HTTPHeaders()
            .setUserProfileId(userId)
            .setBuilderVersion(Adapty.uiBuilderVersion)
            .setBuilderConfigurationFormatVersion(Adapty.uiSchemaVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        logParams = [
            "api_prefix": apiKeyPrefix,
            "placement_id": placementId,
            "variation_id": variationId,
            "builder_version": Adapty.uiBuilderVersion,
            "builder_config_format_version": Adapty.uiSchemaVersion,
            "md5": md5Hash,
            "disable_server_cache": disableServerCache,
        ]
    }
}

private struct FetchOnboardingRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    let requestName = BackendRequestName.fetchOnboarding
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

extension Backend.MainExecutor {
    func fetchPlacement<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale? = nil,
        cached: Content?,
        disableServerCache: Bool
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let request: BackendRequest =
            if Content.self == AdaptyFlow.self {
                FetchFlowRequest(
                    apiKeyPrefix: apiKeyPrefix,
                    userId: userId,
                    placementId: placementId,
                    variationId: variationId,
                    disableServerCache: disableServerCache
                )
            } else {
                FetchOnboardingRequest(
                    apiKeyPrefix: apiKeyPrefix,
                    userId: userId,
                    placementId: placementId,
                    variationId: variationId,
                    locale: locale ?? .defaultPlacementLocale,
                    disableServerCache: disableServerCache
                )
            }

        let response = try await perform(request, withDecoder: AdaptyPlacementChosen.createDecoder(
            withUserId: userId,
            withRequestLocale: locale,
            withCached: cached
        ))

        return response.body
    }
}


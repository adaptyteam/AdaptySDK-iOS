//
//  FetchPlacementRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

private struct FetchPlacementRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    let requestName: BackendRequestName
    let logParams: EventParameters?

    init<Content: PlacementContent>(
        _ type: Content.Type,
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) throws(HTTPError) {
        if type == AdaptyFlow.self {
            let md5Hash = "{\"builder_version\":\"\(Adapty.uiBuilderVersion)\",\"store\":\"app_store\"}".md5.hexString

            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/flow/variations/\(placementId)/\(md5Hash)/\(variationId)/"
            )

            headers = HTTPHeaders()
                .setUserProfileId(userId)
                .setBuilderVersion(Adapty.uiBuilderVersion)
                .setBuilderConfigurationFormatVersion(Adapty.uiSchemaVersion)

            requestName = .fetchFlow
            logParams = [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "variation_id": variationId,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        } else if type == AdaptyOnboarding.self {
            let md5Hash = "{\"locale\":\"\(locale.id.lowercased())\"}".md5.hexString

            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(md5Hash)/\(variationId)/"
            )

            headers = HTTPHeaders()
                .setOnboardingLocale(locale)
                .setUserProfileId(userId)
                .setOnboardingUIVersion(AdaptyOnboarding.viewConfigurationVersion)

            requestName = .fetchOnboarding
            logParams = [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "variation_id": variationId,
                "locale": locale,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        } else {
            throw .notAvailable("Not available for \(String(describing: Content.self))")
        }

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.MainExecutor {
    func fetchPlacement<Content: PlacementContent>(
        _ type: Content.Type,
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale? = nil,
        disableServerCache: Bool
    ) async throws(HTTPError) -> AdaptyPlacement.Draw<Content> {
        let request = try FetchPlacementRequest(
            type,
            apiKeyPrefix: apiKeyPrefix,
            userId: userId,
            placementId: placementId,
            variationId: variationId,
            locale: locale ?? .defaultPlacementLocale,
            disableServerCache: disableServerCache
        )

        let response = try await perform(request, withDecoder: AdaptyPlacement.Draw<Content>.placementDecoder(
            withUserId: userId,
            withVariationId: variationId,
            withRequestLocale: locale
        ))

        return response.body
    }

    func preloadPlacement<Content: PlacementContent>(
        _ type: Content.Type,
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale? = nil,
        disableServerCache: Bool
    ) async throws(HTTPError) {
        let request = try FetchPlacementRequest(
            type,
            apiKeyPrefix: apiKeyPrefix,
            userId: userId,
            placementId: placementId,
            variationId: variationId,
            locale: locale ?? .defaultPlacementLocale,
            disableServerCache: disableServerCache
        )

        _ = try await perform(
            request,
            withDecoder: AdaptyPlacement.Draw<Content>.persistPlacement(
                withVariationId: variationId,
                withRequestLocale: locale
            )
        )
    }
}

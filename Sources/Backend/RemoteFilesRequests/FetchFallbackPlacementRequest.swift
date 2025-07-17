//
//  FetchFallbackPlacementRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

private struct FetchFallbackPlacementRequest: HTTPRequest {
    let endpoint: HTTPEndpoint
    let queryItems: QueryItems
    let stamp = Log.stamp
    let timeoutInterval: TimeInterval?

    init(
        endpoint: HTTPEndpoint,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) {
        self.timeoutInterval =
            if let timeoutInterval {
                max(0.5, timeoutInterval)
            } else {
                nil
            }

        self.endpoint = endpoint
        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.FallbackExecutor {
    @inlinable
    func fetchFallbackPlacement<Content: PlacementContent>(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        cached: Content?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws -> AdaptyPlacementChosen<Content> {
        try await _fetchFallbackPlacement(
            apiKeyPrefix,
            profileId,
            placementId,
            paywallVariationId,
            locale: locale,
            locale,
            cached,
            disableServerCache,
            timeoutInterval
        )
    }

    private func _fetchFallbackPlacement<Content: PlacementContent>(
        _ apiKeyPrefix: String,
        _ profileId: String,
        _ placementId: String,
        _ paywallVariationId: String,
        locale: AdaptyLocale,
        _ requestLocale: AdaptyLocale,
        _ cached: Content?,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?
    ) async throws -> AdaptyPlacementChosen<Content> {
        let endpoint: HTTPEndpoint
        let requestName: APIRequestName

        if Content.self == AdaptyPaywall.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(paywallVariationId)/app_store/\(locale.languageCode)/\(AdaptyViewConfiguration.builderVersion)/fallback.json"
            )
            requestName = .fetchFallbackPaywall
        } else {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(paywallVariationId)/\(locale.languageCode)/fallback.json"
            )
            requestName = .fetchFallbackPaywall
        }

        let request = FetchFallbackPlacementRequest(
            endpoint: endpoint,
            disableServerCache: disableServerCache,
            timeoutInterval: timeoutInterval
        )

        let startRequestTime = Date()

        do {
            let configuration = session.configuration as? HTTPCodableConfiguration

            let response = try await perform(
                request,
                requestName: requestName,
                logParams: [
                    "api_prefix": apiKeyPrefix,
                    "placement_id": placementId,
                    "variation_id": paywallVariationId,
                    "builder_version": AdaptyViewConfiguration.builderVersion,
                    "builder_config_format_version": AdaptyViewConfiguration.formatVersion,
                    "language_code": locale.languageCode,
                    "request_locale": requestLocale.id,
                    "disable_server_cache": disableServerCache,
                ]
            ) { @Sendable response in
                try await AdaptyPlacementChosen.decodePlacementResponse(
                    response,
                    withConfiguration: configuration,
                    withProfileId: profileId,
                    withRequestLocale: requestLocale,
                    withCached: cached
                )
            }

            return response.body
        } catch {
            guard (error as? HTTPError)?.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPlacementLocale)
            else {
                throw error
            }

            return try await _fetchFallbackPlacement(
                apiKeyPrefix,
                profileId,
                placementId,
                paywallVariationId,
                locale: .defaultPlacementLocale,
                requestLocale,
                cached,
                disableServerCache,
                timeoutInterval?.added(startRequestTime.timeIntervalSinceNow)
            )
        }
    }
}

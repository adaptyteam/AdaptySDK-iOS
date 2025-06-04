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
        self.timeoutInterval = if let timeoutInterval {
            max(0.5, timeoutInterval)
        } else {
            nil
        }

        self.endpoint = endpoint
        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.FallbackExecutor {
    func fetchFallbackPlacement<Content: AdaptyPlacementContent>(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        cached: Content?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
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
        } catch {
            guard (error as? HTTPError)?.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPlacementLocale)
            else {
                throw error
            }

            return try await fetchFallbackPlacement(
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                paywallVariationId: paywallVariationId,
                locale: .defaultPlacementLocale,
                cached: cached,
                disableServerCache: disableServerCache,
                timeoutInterval: timeoutInterval?.added(startRequestTime.timeIntervalSinceNow)
            )
        }
    }
}

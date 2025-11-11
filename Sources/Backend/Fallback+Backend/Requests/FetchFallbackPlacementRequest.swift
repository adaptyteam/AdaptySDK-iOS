//
//  FetchFallbackPlacementRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

private struct FetchFallbackPlacementRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let queryItems: QueryItems
    let stamp = Log.stamp
    let timeoutInterval: TimeInterval?
    let logName: APIRequestName
    let logParams: EventParameters?

    init(
        endpoint: HTTPEndpoint,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?,
        logName: APIRequestName,
        logParams: EventParameters
    ) {
        self.timeoutInterval =
            if let timeoutInterval {
                min(max(0.5, timeoutInterval), 60)
            } else {
                nil
            }

        self.endpoint = endpoint
        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        self.logName = logName
        self.logParams = logParams
    }
}

extension Backend.FallbackExecutor {
    @inlinable
    func fetchFallbackPlacement<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        cached: Content?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        try await _fetchFallbackPlacement(
            apiKeyPrefix,
            userId,
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
        _ userId: AdaptyUserId,
        _ placementId: String,
        _ paywallVariationId: String,
        locale: AdaptyLocale,
        _ requestLocale: AdaptyLocale,
        _ cached: Content?,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let endpoint: HTTPEndpoint
        let requestName: APIRequestName

        if Content.self == AdaptyPaywall.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(paywallVariationId)/app_store/\(locale.languageCode)/\(Adapty.uiBuilderVersion)/fallback.json"
            )
            requestName = .fetchFallbackPaywall
        } else {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(paywallVariationId)/\(locale.languageCode)/fallback.json"
            )
            requestName = .fetchFallbackPaywall
        }

        let logParams: EventParameters = [
            "api_prefix": apiKeyPrefix,
            "placement_id": placementId,
            "variation_id": paywallVariationId,
            "builder_version": Adapty.uiBuilderVersion,
            "builder_config_format_version": Adapty.uiSchemaVersion,
            "language_code": locale.languageCode,
            "request_locale": requestLocale.id,
            "disable_server_cache": disableServerCache,
        ]

        let request = FetchFallbackPlacementRequest(
            endpoint: endpoint,
            disableServerCache: disableServerCache,
            timeoutInterval: timeoutInterval,
            logName: requestName,
            logParams: logParams
        )

        let startRequestTime = Date()

        do {
            let response = try await perform(request, withDecoder: AdaptyPlacementChosen.createDecoder(
                withUserId: userId,
                withRequestLocale: requestLocale,
                withCached: cached
            ))

            return response.body
        } catch {
            guard error.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPlacementLocale)
            else {
                throw error
            }

            return try await _fetchFallbackPlacement(
                apiKeyPrefix,
                userId,
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

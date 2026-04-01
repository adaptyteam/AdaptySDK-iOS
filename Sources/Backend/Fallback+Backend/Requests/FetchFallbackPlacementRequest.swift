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
    let requestName: BackendRequestName
    let logParams: EventParameters?

    init(
        endpoint: HTTPEndpoint,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?,
        logName: BackendRequestName,
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

        requestName = logName
        self.logParams = logParams
    }
}

extension Backend.FallbackExecutor {
    @inlinable
    func fetchFallbackPlacement<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale? = nil,
        cached: Content?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        if let locale {
            try await _fetchFallbackPlacementByLocale(
                apiKeyPrefix,
                userId,
                placementId,
                variationId,
                locale: locale,
                locale,
                cached,
                disableServerCache,
                timeoutInterval
            )
        } else {
            try await _fetchFallbackPlacement(
                apiKeyPrefix,
                userId,
                placementId,
                variationId,
                cached,
                disableServerCache,
                timeoutInterval
            )
        }
    }

    private func _fetchFallbackPlacement<Content: PlacementContent>(
        _ apiKeyPrefix: String,
        _ userId: AdaptyUserId,
        _ placementId: String,
        _ variationId: String,
        _ cached: Content?,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let endpoint: HTTPEndpoint
        let requestName: BackendRequestName

        if Content.self == AdaptyFlow.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/flow/variations/\(placementId)/\(variationId)/app_store/\(Adapty.uiBuilderVersion)/fallback.json"
            )
            requestName = .fetchFallbackFlow
        } else {
            throw .notAvailable("Not available for \(String(describing: Content.self))")
        }

        let logParams: EventParameters = [
            "api_prefix": apiKeyPrefix,
            "placement_id": placementId,
            "variation_id": variationId,
            "builder_version": Adapty.uiBuilderVersion,
            "builder_config_format_version": Adapty.uiSchemaVersion,
            "disable_server_cache": disableServerCache,
        ]

        let request = FetchFallbackPlacementRequest(
            endpoint: endpoint,
            disableServerCache: disableServerCache,
            timeoutInterval: timeoutInterval,
            logName: requestName,
            logParams: logParams
        )

        let response = try await perform(request, withDecoder: AdaptyPlacementChosen.createDecoder(
            withUserId: userId,
            withCached: cached
        ))

        return response.body
    }

    private func _fetchFallbackPlacementByLocale<Content: PlacementContent>(
        _ apiKeyPrefix: String,
        _ userId: AdaptyUserId,
        _ placementId: String,
        _ variationId: String,
        locale: AdaptyLocale,
        _ requestLocale: AdaptyLocale,
        _ cached: Content?,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let endpoint: HTTPEndpoint
        let requestName: BackendRequestName

        if Content.self == AdaptyOnboarding.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(variationId)/\(locale.languageCode)/fallback.json"
            )
            requestName = .fetchFallbackOnbording
        } else {
            throw .notAvailable("Not available for \(String(describing: Content.self))")
        }

        let logParams: EventParameters = [
            "api_prefix": apiKeyPrefix,
            "placement_id": placementId,
            "variation_id": variationId,
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

            return try await _fetchFallbackPlacementByLocale(
                apiKeyPrefix,
                userId,
                placementId,
                variationId,
                locale: .defaultPlacementLocale,
                requestLocale,
                cached,
                disableServerCache,
                timeoutInterval?.added(startRequestTime.timeIntervalSinceNow)
            )
        }
    }
}


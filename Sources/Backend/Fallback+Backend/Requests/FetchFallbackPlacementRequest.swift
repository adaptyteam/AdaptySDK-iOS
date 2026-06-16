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
    func fetchFallbackPlacement<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale? = nil,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        try await _fetchFallbackPlacement(
            apiKeyPrefix,
            userId,
            placementId,
            variationId,
            locale ?? .defaultPlacementLocale,
            disableServerCache,
            timeoutInterval
        )
    }
}

extension Backend.ConfigsExecutor {
    func fetchPlacementForDefaultAudience<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale? = nil,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        try await _fetchFallbackPlacement(
            apiKeyPrefix,
            userId,
            placementId,
            variationId,
            locale ?? .defaultPlacementLocale,
            disableServerCache,
            timeoutInterval
        )
    }
}

private extension BackendExecutor {
    func _fetchFallbackPlacement<Content: PlacementContent>(
        _ apiKeyPrefix: String,
        _ userId: AdaptyUserId,
        _ placementId: String,
        _ variationId: String,
        _ requestLocale: AdaptyLocale,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        var locale = requestLocale
        var timeoutInterval = timeoutInterval
        var lastError: HTTPError
        repeat {
            let endpoint: HTTPEndpoint
            let requestName: BackendRequestName
            let logParams: EventParameters
            if Content.self == AdaptyFlow.self {
                endpoint = HTTPEndpoint(
                    method: .get,
                    path:
                    "/sdk/in-apps/\(apiKeyPrefix)/flow/variations/\(placementId)/\(variationId)/app_store/fallback.json"
                )
                requestName = .fetchFallbackFlow
                logParams = [
                    "api_prefix": apiKeyPrefix,
                    "placement_id": placementId,
                    "variation_id": variationId,
                    "builder_version": Adapty.uiBuilderVersion,
                    "builder_config_format_version": Adapty.uiSchemaVersion,
                    "disable_server_cache": disableServerCache,
                ]

            } else if Content.self == AdaptyOnboarding.self {
                endpoint = HTTPEndpoint(
                    method: .get,
                    path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(variationId)/\(locale.languageCode)/fallback.json"
                )
                requestName = .fetchFallbackOnbording
                logParams = [
                    "api_prefix": apiKeyPrefix,
                    "placement_id": placementId,
                    "variation_id": variationId,
                    "builder_version": Adapty.uiBuilderVersion,
                    "builder_config_format_version": Adapty.uiSchemaVersion,
                    "language_code": locale.languageCode,
                    "request_locale": requestLocale.id,
                    "disable_server_cache": disableServerCache,
                ]

            } else {
                throw .notAvailable("Not available for \(String(describing: Content.self))")
            }

            let request = FetchFallbackPlacementRequest(
                endpoint: endpoint,
                disableServerCache: disableServerCache,
                timeoutInterval: timeoutInterval,
                logName: requestName,
                logParams: logParams
            )

            let startRequestTime = Date()

            do throws(HTTPError) {
                let response = try await perform(request, withDecoder: AdaptyPlacement.Draw<Content>.placementDecoder(
                    withUserId: userId,
                    withVariationId: variationId,
                    withRequestLocale: requestLocale
                ))

                return .draw(response.body)

            } catch {
                if error.statusCode == 404,
                   Content.self == AdaptyOnboarding.self,
                   !locale.equalLanguageCode(AdaptyLocale.defaultPlacementLocale)
                {
                    locale = .defaultPlacementLocale
                    timeoutInterval = timeoutInterval?.added(startRequestTime.timeIntervalSinceNow)
                    lastError = error
                    continue
                } else {
                    throw error
                }
            }
        } while !Task.isCancelled

        throw lastError
    }
}

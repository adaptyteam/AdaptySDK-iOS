//
//  FetchFallbackPlacementVariationsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchFallbackPlacementVariationsRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let stamp = Log.stamp
    let queryItems: QueryItems
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

private extension BackendExecutor {
    @inline(__always)
    func performFetchFallbackPlacementVariationsRequest<Content: PlacementContent>(
        requestName: APIRequestName,
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale,
        cached: Content?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        try await _performFetchFallbackPlacementVariationsRequest(
            requestName,
            apiKeyPrefix,
            userId,
            placementId,
            locale: locale,
            locale,
            cached,
            crossPlacementEligible,
            variationIdResolver,
            disableServerCache,
            timeoutInterval
        )
    }

    private func _performFetchFallbackPlacementVariationsRequest<Content: PlacementContent>(
        _ requestName: APIRequestName,
        _ apiKeyPrefix: String,
        _ userId: AdaptyUserId,
        _ placementId: String,
        locale: AdaptyLocale,
        _ requestLocale: AdaptyLocale,
        _ cached: Content?,
        _ crossPlacementEligible: Bool,
        _ variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let endpoint =
            if Content.self == AdaptyPaywall.self {
                HTTPEndpoint(
                    method: .get,
                    path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/app_store/\(locale.languageCode.lowercased())/\(Adapty.uiBuilderVersion)/fallback.json"
                )
            } else {
                HTTPEndpoint(
                    method: .get,
                    path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(locale.languageCode.lowercased())/fallback.json"
                )
            }

        let request = FetchFallbackPlacementVariationsRequest(
            endpoint: endpoint,
            disableServerCache: disableServerCache,
            timeoutInterval: timeoutInterval,
            logName: requestName,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "language_code": locale.languageCode,
                "request_locale": requestLocale.id,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "disable_server_cache": disableServerCache,
            ]
        )

        let startRequestTime = Date()

        do {
            let response = try await perform(request, withDecoder: AdaptyPlacementChosen.createDecoder(
                withUserId: userId,
                withPlacementId: placementId,
                withRequestLocale: requestLocale,
                withCached: cached,
                variationIdResolver: variationIdResolver
            ))

            return response.body

        } catch {
            guard error.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPlacementLocale)
            else {
                throw error
            }

            return try await _performFetchFallbackPlacementVariationsRequest(
                requestName,
                apiKeyPrefix,
                userId,
                placementId,
                locale: .defaultPlacementLocale,
                requestLocale,
                cached,
                crossPlacementEligible,
                variationIdResolver,
                disableServerCache,
                timeoutInterval?.added(startRequestTime.timeIntervalSinceNow)
            )
        }
    }
}

extension Backend.FallbackExecutor {
    func fetchFallbackPlacementVariations<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale,
        cached: Content?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let requestName: APIRequestName =
            if Content.self == AdaptyPaywall.self {
                .fetchFallbackPaywallVariations
            } else {
                .fetchFallbackOnboardingVariations
            }
        return try await performFetchFallbackPlacementVariationsRequest(
            requestName: requestName,
            apiKeyPrefix: apiKeyPrefix,
            userId: userId,
            placementId: placementId,
            locale: locale,
            cached: cached,
            crossPlacementEligible: crossPlacementEligible,
            variationIdResolver: variationIdResolver,
            disableServerCache: disableServerCache,
            timeoutInterval: timeoutInterval
        )
    }
}

extension Backend.ConfigsExecutor {
    func fetchPlacementVariationsForDefaultAudience<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale,
        cached: Content?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let requestName: APIRequestName =
            if Content.self == AdaptyPaywall.self {
                .fetchPaywallVariationsForDefaultAudience
            } else {
                .fetchOnboardingVariationsForDefaultAudience
            }
        return try await performFetchFallbackPlacementVariationsRequest(
            requestName: requestName,
            apiKeyPrefix: apiKeyPrefix,
            userId: userId,
            placementId: placementId,
            locale: locale,
            cached: cached,
            crossPlacementEligible: crossPlacementEligible,
            variationIdResolver: variationIdResolver,
            disableServerCache: disableServerCache,
            timeoutInterval: timeoutInterval
        )
    }
}

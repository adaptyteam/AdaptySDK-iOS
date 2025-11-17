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

private extension BackendExecutor {
    func performFetchFallbackPlacementVariationsRequest<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale,
        requestLocale: AdaptyLocale,
        cached: Content?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let endpoint: HTTPEndpoint
        let requestName: BackendRequestName
        if Content.self == AdaptyPaywall.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/app_store/\(locale.languageCode.lowercased())/\(Adapty.uiBuilderVersion)/fallback.json"
            )
            requestName = kind == .fallback ? .fetchFallbackPaywallVariations : .fetchPaywallVariationsForDefaultAudience

        } else {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(locale.languageCode.lowercased())/fallback.json"
            )
            requestName = kind == .fallback ? .fetchFallbackOnboardingVariations : .fetchOnboardingVariationsForDefaultAudience
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

            return try await performFetchFallbackPlacementVariationsRequest(
                apiKeyPrefix: apiKeyPrefix,
                userId: userId,
                placementId: placementId,
                locale: .defaultPlacementLocale,
                requestLocale: requestLocale,
                cached: cached,
                crossPlacementEligible: crossPlacementEligible,
                variationIdResolver: variationIdResolver,
                disableServerCache: disableServerCache,
                timeoutInterval: timeoutInterval?.added(startRequestTime.timeIntervalSinceNow)
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
        try await performFetchFallbackPlacementVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            userId: userId,
            placementId: placementId,
            locale: locale,
            requestLocale: locale,
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
        try await performFetchFallbackPlacementVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            userId: userId,
            placementId: placementId,
            locale: locale,
            requestLocale: locale,
            cached: cached,
            crossPlacementEligible: crossPlacementEligible,
            variationIdResolver: variationIdResolver,
            disableServerCache: disableServerCache,
            timeoutInterval: timeoutInterval
        )
    }
}

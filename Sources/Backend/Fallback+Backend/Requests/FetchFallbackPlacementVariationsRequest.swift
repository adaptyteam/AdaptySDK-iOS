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

extension Backend.FallbackExecutor {
    func fetchFallbackPlacementVariations<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale? = nil,
        cached: Content?,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        if Content.self == AdaptyOnboarding.self {
            let locale = locale ?? .defaultPlacementLocale
            return try await _performFetchFallbackPlacementVariationsRequestByLocale(
                apiKeyPrefix,
                userId,
                placementId,
                locale: locale,
                locale,
                cached,
                variationIdResolver,
                disableServerCache,
                timeoutInterval
            )
        } else {
            return try await _performFetchFallbackPlacementVariationsRequest(
                apiKeyPrefix,
                userId,
                placementId,
                cached,
                variationIdResolver,
                disableServerCache,
                timeoutInterval
            )
        }
    }
}

extension Backend.ConfigsExecutor {
    func fetchPlacementVariationsForDefaultAudience<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale? = nil,
        cached: Content?,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        if Content.self == AdaptyOnboarding.self {
            let locale = locale ?? .defaultPlacementLocale
            return try await _performFetchFallbackPlacementVariationsRequestByLocale(
                apiKeyPrefix,
                userId,
                placementId,
                locale: locale,
                locale,
                cached,
                variationIdResolver,
                disableServerCache,
                timeoutInterval
            )
        } else {
            return try await _performFetchFallbackPlacementVariationsRequest(
                apiKeyPrefix,
                userId,
                placementId,
                cached,
                variationIdResolver,
                disableServerCache,
                timeoutInterval
            )
        }
    }
}

private extension BackendExecutor {
    func _performFetchFallbackPlacementVariationsRequest<Content: PlacementContent>(
        _ apiKeyPrefix: String,
        _ userId: AdaptyUserId,
        _ placementId: String,
        _ cached: Content?,
        _ variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let endpoint: HTTPEndpoint
        let requestName: BackendRequestName
        if Content.self == AdaptyFlow.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/flow/variations/\(placementId)/app_store/fallback.json"
            )
            requestName = kind == .fallback ? .fetchFallbackPaywallVariations : .fetchPaywallVariationsForDefaultAudience

        } else {
            throw .notAvailable("Not available for \(String(describing: Content.self))")
        }

        let request = FetchFallbackPlacementVariationsRequest(
            endpoint: endpoint,
            disableServerCache: disableServerCache,
            timeoutInterval: timeoutInterval,
            logName: requestName,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "disable_server_cache": disableServerCache,
            ]
        )

        let response = try await perform(request, withDecoder: AdaptyPlacementChosen.createDecoder(
            withUserId: userId,
            withPlacementId: placementId,
            withCached: cached,
            variationIdResolver: variationIdResolver
        ))

        return response.body
    }

    func _performFetchFallbackPlacementVariationsRequestByLocale<Content: PlacementContent>(
        _ apiKeyPrefix: String,
        _ userId: AdaptyUserId,
        _ placementId: String,
        locale: AdaptyLocale,
        _ requestLocale: AdaptyLocale,
        _ cached: Content?,
        _ variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let endpoint: HTTPEndpoint
        let requestName: BackendRequestName
        if Content.self == AdaptyOnboarding.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path: 
                    "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(locale.languageCode.lowercased())/fallback.json"
            )
            requestName = kind == .fallback ? .fetchFallbackOnboardingVariations : .fetchOnboardingVariationsForDefaultAudience

        } else {
            throw .notAvailable("Not available for \(String(describing: Content.self))")
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

            return try await _performFetchFallbackPlacementVariationsRequestByLocale(
                apiKeyPrefix,
                userId,
                placementId,
                locale: .defaultPlacementLocale,
                requestLocale,
                cached,
                variationIdResolver,
                disableServerCache,
                timeoutInterval?.added(startRequestTime.timeIntervalSinceNow)
            )
        }
    }
}


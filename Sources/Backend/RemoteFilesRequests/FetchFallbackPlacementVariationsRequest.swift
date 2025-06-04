//
//  FetchFallbackPlacementVariationsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchFallbackPlacementVariationsRequest: HTTPRequest {
    let endpoint: HTTPEndpoint
    let stamp = Log.stamp
    let queryItems: QueryItems
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

private extension BackendExecutor {
    @inline(__always)
    func performFetchFallbackPlacementVariationsRequest<Content: AdaptyPlacementContent>(
        requestName: APIRequestName,
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: Content?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws -> AdaptyPlacementChosen<Content> {
        let endpoint =
            if Content.self == AdaptyPaywall.self {
                HTTPEndpoint(
                    method: .get,
                    path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/app_store/\(locale.languageCode.lowercased())/\(AdaptyViewConfiguration.builderVersion)/fallback.json"
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
            timeoutInterval: timeoutInterval
        )

        let startRequestTime = Date()

        do {
            let configuration = session.configuration as? HTTPCodableConfiguration

            let response: HTTPResponse<AdaptyPlacementChosen> = try await perform(
                request,
                requestName: requestName,
                logParams: [
                    "api_prefix": apiKeyPrefix,
                    "placement_id": placementId,
                    "language_code": locale.languageCode,
                    "builder_version": AdaptyViewConfiguration.builderVersion,
                    "builder_config_format_version": AdaptyViewConfiguration.formatVersion,
                    "disable_server_cache": disableServerCache,
                ]
            ) { @Sendable response in
                try await AdaptyPlacementChosen.decodePlacementVariationsResponse(
                    response,
                    withConfiguration: configuration,
                    withProfileId: profileId,
                    withPlacementId: placementId,
                    withCached: cached,
                    variationIdResolver: variationIdResolver
                )
            }

            return response.body

        } catch {
            guard (error as? HTTPError)?.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPlacementLocale)
            else {
                throw error
            }

            return try await performFetchFallbackPlacementVariationsRequest(
                requestName: requestName,
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                locale: .defaultPlacementLocale,
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
    func fetchFallbackPlacementVariations<Content: AdaptyPlacementContent>(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: Content?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws -> AdaptyPlacementChosen<Content> {
        let requestName: APIRequestName =
            if Content.self == AdaptyPaywall.self {
                .fetchFallbackPaywallVariations
            } else {
                .fetchFallbackOnboardingVariations
            }
        return try await performFetchFallbackPlacementVariationsRequest(
            requestName: requestName,
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
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
    func fetchPlacementVariationsForDefaultAudience<Content: AdaptyPlacementContent>(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: Content?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws -> AdaptyPlacementChosen<Content> {
        let requestName: APIRequestName =
            if Content.self == AdaptyPaywall.self {
                .fetchPaywallVariationsForDefaultAudience
            } else {
                .fetchOnboardingVariationsForDefaultAudience
            }
        return try await performFetchFallbackPlacementVariationsRequest(
            requestName: requestName,
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
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

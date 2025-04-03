//
//  FetchFallbackPaywallVariationsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchFallbackPaywallVariationsRequest: HTTPRequest {
    let endpoint: HTTPEndpoint
    let stamp = Log.stamp
    let queryItems: QueryItems
    let timeoutInterval: TimeInterval?

    init(
        apiKeyPrefix: String,
        placementId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) {
        self.timeoutInterval = if let timeoutInterval {
            max(0.5, timeoutInterval)
        } else {
            nil
        }

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/app_store/\(locale.languageCode.lowercased())/\(AdaptyViewConfiguration.builderVersion)/fallback.json"
        )
        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

private extension BackendExecutor {
    @inline(__always)
    func performFetchFallbackPaywallVariationsRequest(
        requestName: APIRequestName,
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPaywallChosen.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws -> AdaptyPaywallChosen {
        let request = FetchFallbackPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            placementId: placementId,
            locale: locale,
            disableServerCache: disableServerCache,
            timeoutInterval: timeoutInterval
        )

        let startRequestTime = Date()

        do {
            let configuration = session.configuration as? HTTPCodableConfiguration

            let response: HTTPResponse<AdaptyPaywallChosen> = try await perform(
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
                try await AdaptyPaywallChosen.decodePaywallVariationsResponse(
                    response,
                    withConfiguration: configuration,
                    withProfileId: profileId,
                    withPlacemantId: placementId,
                    withCachedPaywall: cached,
                    variationIdResolver: variationIdResolver
                )
            }

            return response.body

        } catch {
            guard (error as? HTTPError)?.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPaywallLocale)
            else {
                throw error
            }

            return try await performFetchFallbackPaywallVariationsRequest(
                requestName: requestName,
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                locale: .defaultPaywallLocale,
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
    func fetchFallbackPaywallVariations(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPaywallChosen.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws -> AdaptyPaywallChosen {
        try await performFetchFallbackPaywallVariationsRequest(
            requestName: .fetchFallbackPaywallVariations,
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
    func fetchUntargetedPaywallVariations(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPaywallChosen.VariationIdResolver?,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws -> AdaptyPaywallChosen {
        try await performFetchFallbackPaywallVariationsRequest(
            requestName: .fetchUntargetedPaywallVariations,
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

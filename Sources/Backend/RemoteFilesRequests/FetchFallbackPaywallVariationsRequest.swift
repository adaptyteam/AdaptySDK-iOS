//
//  FetchFallbackPaywallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchFallbackPaywallVariationsRequest: HTTPRequest {
    let endpoint: HTTPEndpoint
    let stamp = Log.stamp
    let queryItems: QueryItems
    let timeoutInterval: TimeInterval? = 0.5

    init(
        apiKeyPrefix: String,
        placementId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/app_store/\(locale.languageCode.lowercased())/\(AdaptyViewConfiguration.builderVersion)/fallback.json"
        )
        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

protocol FetchFallbackPaywallVariationsExecutor: BackendExecutor {
    func fetchFallbackPaywallVariations(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPaywallChosen.VariationIdResolver?,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen

    func fetchFallbackPaywall(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen
}

private extension FetchFallbackPaywallVariationsExecutor {
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
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen {
        let request = FetchFallbackPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            placementId: placementId,
            locale: locale,
            disableServerCache: disableServerCache
        )

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
                try await AdaptyPaywallChosen.decodeResponse(
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
                disableServerCache: disableServerCache
            )
        }
    }
}

extension Backend.FallbackExecutor: FetchFallbackPaywallVariationsExecutor {
    func fetchFallbackPaywallVariations(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPaywallChosen.VariationIdResolver?,
        disableServerCache: Bool
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
            disableServerCache: disableServerCache
        )
    }

    func fetchFallbackPaywall(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen {
        try await performFetchFallbackPaywall(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            paywallVariationId: paywallVariationId,
            locale: locale,
            disableServerCache: disableServerCache
        )
    }
}

extension Backend.ConfigsExecutor: FetchFallbackPaywallVariationsExecutor {
    func fetchFallbackPaywallVariations(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPaywallChosen.VariationIdResolver?,
        disableServerCache: Bool
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
            disableServerCache: disableServerCache
        )
    }

    func fetchFallbackPaywall(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen {
        try await performFetchFallbackPaywall(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            paywallVariationId: paywallVariationId,
            locale: locale,
            disableServerCache: disableServerCache
        )
    }
}

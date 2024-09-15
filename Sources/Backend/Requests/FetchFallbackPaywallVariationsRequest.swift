//
//  FetchFallbackPaywallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchFallbackPaywallVariationsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyPaywallChosen

    let endpoint: HTTPEndpoint
    let profileId: String
    let stamp = Log.stamp

    let cached: AdaptyPaywall?
    let queryItems: QueryItems

    func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?
    ) throws -> Response {
        try Self.decodeDataResponse(
            response,
            withConfiguration: configuration,
            withProfileId: profileId,
            withCachedPaywall: cached
        )
    }

    init(apiKeyPrefix: String, profileId: String, placementId: String, locale: AdaptyLocale, cached: AdaptyPaywall?, disableServerCache: Bool) {
        self.profileId = profileId
        self.cached = cached
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/app_store/\(locale.languageCode.lowercased())/\(AdaptyUI.builderVersion)/fallback.json"
        )
        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension HTTPSession {
    @inline(__always)
    private func performFetchFallbackPaywallVariationsRequest(
        requestName: APIRequestName,
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen {
        let request = FetchFallbackPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            cached: cached,
            disableServerCache: disableServerCache
        )

        do {
            let response = try await perform(
                request,
                requestName: requestName,
                logParams: [
                    "api_prefix": apiKeyPrefix,
                    "placement_id": placementId,
                    "language_code": locale.languageCode,
                    "builder_version": AdaptyUI.builderVersion,
                    "builder_config_format_version": AdaptyUI.configurationFormatVersion,
                    "disable_server_cache": disableServerCache,
                ]
            )
            return response.body
        } catch {
            guard (error as? HTTPError)?.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPaywallLocale) else {
                throw error
            }

            return try await performFetchFallbackPaywallVariationsRequest(
                requestName: requestName,
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                locale: .defaultPaywallLocale,
                cached: cached,
                disableServerCache: disableServerCache
            )
        }
    }

    func performFetchFallbackPaywallVariationsRequest(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen {
        try await performFetchFallbackPaywallVariationsRequest(
            requestName: .fetchFallbackPaywallVariations,
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            cached: cached,
            disableServerCache: disableServerCache
        )
    }

    func performFetchUntargetedPaywallVariationsRequest(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen {
        try await performFetchFallbackPaywallVariationsRequest(
            requestName: .fetchUntargetedPaywallVariations,
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            cached: cached,
            disableServerCache: disableServerCache
        )
    }
}

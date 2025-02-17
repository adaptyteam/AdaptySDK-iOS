//
//  FetchFallbackPaywallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

struct FetchFallbackPaywallRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyPaywall

    let endpoint: HTTPEndpoint
    let queryItems: QueryItems
    let stamp = Log.stamp

    let timeoutInterval: TimeInterval? = 0.5

    init(
        apiKeyPrefix: String,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(paywallVariationId)/app_store/\(locale.languageCode)/\(AdaptyViewConfiguration.builderVersion)/fallback.json"
        )

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension FetchFallbackPaywallVariationsExecutor {
    func performFetchFallbackPaywall(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen {
        let request = FetchFallbackPaywallRequest(
            apiKeyPrefix: apiKeyPrefix,
            placementId: placementId,
            paywallVariationId: paywallVariationId,
            locale: locale,
            disableServerCache: disableServerCache
        )

        do {
            let response = try await perform(
                request,
                requestName: .fetchFallbackPaywall,
                logParams: [
                    "api_prefix": apiKeyPrefix,
                    "placement_id": placementId,
                    "variation_id": paywallVariationId,
                    "builder_version": AdaptyViewConfiguration.builderVersion,
                    "builder_config_format_version": AdaptyViewConfiguration.formatVersion,
                    "language_code": locale.languageCode,
                    "disable_server_cache": disableServerCache,
                ]
            )

            return AdaptyPaywallChosen.draw(profileId, response.body)
        } catch {
            guard (error as? HTTPError)?.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPaywallLocale)
            else {
                throw error
            }
            return try await performFetchFallbackPaywall(
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                paywallVariationId: paywallVariationId,
                locale: .defaultPaywallLocale,
                disableServerCache: disableServerCache
            )
        }
    }
}

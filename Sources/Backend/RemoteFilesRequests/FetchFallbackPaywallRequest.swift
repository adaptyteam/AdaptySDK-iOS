//
//  FetchFallbackPaywallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

private struct FetchFallbackPaywallRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyPaywall

    let endpoint: HTTPEndpoint
    let queryItems: QueryItems
    let stamp = Log.stamp

    let timeoutInterval: TimeInterval?

    func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?
    ) throws -> Response {
        try Self.decodeResponse(response, withConfiguration: configuration)
    }

    init(
        apiKeyPrefix: String,
        placementId: String,
        paywallVariationId: String,
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
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(paywallVariationId)/app_store/\(locale.languageCode)/\(AdaptyViewConfiguration.builderVersion)/fallback.json"
        )

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.FallbackExecutor {
    func fetchFallbackPaywall(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws -> AdaptyPaywallChosen {
        let request = FetchFallbackPaywallRequest(
            apiKeyPrefix: apiKeyPrefix,
            placementId: placementId,
            paywallVariationId: paywallVariationId,
            locale: locale,
            disableServerCache: disableServerCache,
            timeoutInterval: timeoutInterval
        )

        let startRequestTime = Date()

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

            return .draw(response.body, profileId: profileId)
        } catch {
            guard (error as? HTTPError)?.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPaywallLocale)
            else {
                throw error
            }

            return try await fetchFallbackPaywall(
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                paywallVariationId: paywallVariationId,
                locale: .defaultPaywallLocale,
                disableServerCache: disableServerCache,
                timeoutInterval: timeoutInterval?.added(startRequestTime.timeIntervalSinceNow)
            )
        }
    }
}

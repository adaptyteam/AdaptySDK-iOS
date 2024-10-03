//
//  FetchFallbackViewConfigurationRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

struct FetchFallbackViewConfigurationRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<AdaptyUI.ViewConfiguration>

    let endpoint: HTTPEndpoint
    let queryItems: QueryItems
    let stamp = Log.stamp

    init(apiKeyPrefix: String, paywallInstanceIdentity: String, locale: AdaptyLocale, disableServerCache: Bool) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall-builder/\(paywallInstanceIdentity)/\(AdaptyUI.builderVersion)/\(locale.languageCode)/fallback.json"
        )

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.FallbackExecutor {
    func fetchFallbackViewConfiguration(
        apiKeyPrefix: String,
        paywallInstanceIdentity: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) async throws -> AdaptyUI.ViewConfiguration {
        let request = FetchFallbackViewConfigurationRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallInstanceIdentity: paywallInstanceIdentity,
            locale: locale,
            disableServerCache: disableServerCache
        )

        do {
            let response = try await perform(
                request,
                requestName: .fetchFallbackViewConfiguration,
                logParams: [
                    "api_prefix": apiKeyPrefix,
                    "paywall_instance_id": paywallInstanceIdentity,
                    "builder_version": AdaptyUI.builderVersion,
                    "builder_config_format_version": AdaptyUI.configurationFormatVersion,
                    "language_code": locale.languageCode,
                    "disable_server_cache": disableServerCache,
                ]
            )

            return response.body.value
        } catch {
            guard (error as? HTTPError)?.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPaywallLocale) else {
                throw error
            }
            return try await fetchFallbackViewConfiguration(
                apiKeyPrefix: apiKeyPrefix,
                paywallInstanceIdentity: paywallInstanceIdentity,
                locale: .defaultPaywallLocale,
                disableServerCache: disableServerCache
            )
        }
    }
}

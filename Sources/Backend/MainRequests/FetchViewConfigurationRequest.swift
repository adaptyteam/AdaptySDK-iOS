//
//  FetchViewConfigurationRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

struct FetchViewConfigurationRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Data<AdaptyViewSource>

    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    init(apiKeyPrefix: String, paywallVariationId: String, locale: AdaptyLocale, md5Hash: String, disableServerCache: Bool) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall-builder/\(paywallVariationId)/\(md5Hash)/"
        )

        headers = HTTPHeaders()
            .setPaywallBuilderLocale(locale)
            .setPaywallBuilderVersion(AdaptyViewConfiguration.builderVersion)
            .setPaywallBuilderConfigurationFormatVersion(AdaptyViewConfiguration.formatVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.MainExecutor {
    func fetchViewConfiguration(
        apiKeyPrefix: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) async throws -> AdaptyViewSource {
        let md5Hash = "{\"builder_version\":\"\(AdaptyViewConfiguration.builderVersion)\",\"locale\":\"\(locale.id.lowercased())\"}".md5.hexString

        let request = FetchViewConfigurationRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallVariationId: paywallVariationId,
            locale: locale,
            md5Hash: md5Hash,
            disableServerCache: disableServerCache
        )

        let response = try await perform(
            request,
            requestName: .fetchViewConfiguration,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "variation_id": paywallVariationId,
                "locale": locale,
                "builder_version": AdaptyViewConfiguration.builderVersion,
                "builder_config_format_version": AdaptyViewConfiguration.formatVersion,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        )

        return response.body.value
    }
}

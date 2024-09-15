//
//  FetchViewConfigurationRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

struct FetchViewConfigurationRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<AdaptyUI.ViewConfiguration>

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
            .setViewConfigurationLocale(locale)
            .setVisualBuilderVersion(AdaptyUI.builderVersion)
            .setVisualBuilderConfigurationFormatVersion(AdaptyUI.configurationFormatVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension HTTPSession {
    func performFetchViewConfigurationRequest(
        apiKeyPrefix: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) async throws -> AdaptyUI.ViewConfiguration {
        let md5Hash = "{\"builder_version\":\"\(AdaptyUI.builderVersion)\",\"locale\":\"\(locale.id.lowercased())\"}".md5.hexString

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
                "builder_version": AdaptyUI.builderVersion,
                "builder_config_format_version": AdaptyUI.configurationFormatVersion,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        )

        return response.body.value
    }
}

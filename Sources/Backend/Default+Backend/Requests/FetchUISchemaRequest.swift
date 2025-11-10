//
//  FetchUISchemaRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import AdaptyUIBuilder
import Foundation

struct FetchUISchemaRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Data<AdaptyUISchema>

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
            .setPaywallBuilderVersion(Adapty.uiBuilderVersion)
            .setPaywallBuilderConfigurationFormatVersion(Adapty.uiSchemaVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.DefaultExecutor {
    func fetchUISchema(
        apiKeyPrefix: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) async throws(HTTPError) -> AdaptyUISchema {
        let md5Hash = "{\"builder_version\":\"\(Adapty.uiBuilderVersion)\",\"locale\":\"\(locale.id.lowercased())\"}".md5.hexString

        let request = FetchUISchemaRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallVariationId: paywallVariationId,
            locale: locale,
            md5Hash: md5Hash,
            disableServerCache: disableServerCache
        )

        let response = try await perform(
            request,
            requestName: .fetchUISchema,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "variation_id": paywallVariationId,
                "locale": locale,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        )

        return response.body.value
    }
}

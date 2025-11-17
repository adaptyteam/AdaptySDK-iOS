//
//  FetchUISchemaRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import AdaptyUIBuilder
import Foundation

struct FetchUISchemaRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp
    let requestName = BackendRequestName.fetchUISchema
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        md5Hash: String,
        disableServerCache: Bool,
        logParams: EventParameters?
    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall-builder/\(paywallVariationId)/\(md5Hash)/"
        )

        headers = HTTPHeaders()
            .setPaywallBuilderLocale(locale)
            .setPaywallBuilderVersion(Adapty.uiBuilderVersion)
            .setPaywallBuilderConfigurationFormatVersion(Adapty.uiSchemaVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        self.logParams = logParams
    }
}

private typealias ResponseBody = Backend.Response.Data<AdaptyUISchema>

extension Backend.MainExecutor {
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
            disableServerCache: disableServerCache,
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

        let response: HTTPResponse<ResponseBody> = try await perform(request)
        return response.body.value
    }
}

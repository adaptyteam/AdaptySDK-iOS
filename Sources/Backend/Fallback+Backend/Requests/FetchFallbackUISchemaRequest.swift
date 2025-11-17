//
//  FetchFallbackUISchemaRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import AdaptyUIBuilder
import Foundation

private struct FetchFallbackUISchemaRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let queryItems: QueryItems
    let stamp = Log.stamp
    let requestName = BackendRequestName.fetchFallbackUISchema
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        paywallInstanceIdentity: String,
        locale: AdaptyLocale,
        disableServerCache: Bool,
        logParams: EventParameters

    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall-builder/\(paywallInstanceIdentity)/\(Adapty.uiBuilderVersion)/\(locale.languageCode)/fallback.json"
        )

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        self.logParams = logParams
    }
}

private typealias ResponseBody = Backend.Response.Data<AdaptyUISchema>

extension Backend.FallbackExecutor {
    func fetchFallbackUISchema(
        apiKeyPrefix: String,
        paywallInstanceIdentity: String,
        locale: AdaptyLocale,
        disableServerCache: Bool
    ) async throws(HTTPError) -> AdaptyUISchema {
        let request = FetchFallbackUISchemaRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallInstanceIdentity: paywallInstanceIdentity,
            locale: locale,
            disableServerCache: disableServerCache,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "paywall_instance_id": paywallInstanceIdentity,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "language_code": locale.languageCode,
                "disable_server_cache": disableServerCache,
            ]
        )

        do {
            let response: HTTPResponse<ResponseBody> = try await perform(request)
            return response.body.value
        } catch {
            guard error.statusCode == 404,
                  !locale.equalLanguageCode(AdaptyLocale.defaultPlacementLocale)
            else {
                throw error
            }
            return try await fetchFallbackUISchema(
                apiKeyPrefix: apiKeyPrefix,
                paywallInstanceIdentity: paywallInstanceIdentity,
                locale: .defaultPlacementLocale,
                disableServerCache: disableServerCache
            )
        }
    }
}

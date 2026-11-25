//
//  FetchFallbackUISchemaRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.04.2026.
//

import AdaptyUIBuilder
import Foundation

private struct FetchFallbackUISchemaRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp
    let requestName = BackendRequestName.fetchFallBackUISchema
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        flowId: String,
        flowLayoutVariant: AdaptyFlow.LayoutVariant,
        flowLocale: String?,
        disableServerCache: Bool,
        logParams: EventParameters?
    ) {

        let path =
            if let flowLocale {
                "sdk/in-apps/\(apiKeyPrefix)/flow/\(flowId)/version/\(flowLayoutVariant.versionId)/layout/\(flowLayoutVariant.id)/\(flowLocale.base64URLEncoded)/config/"
            } else {
                "sdk/in-apps/\(apiKeyPrefix)/flow/\(flowId)/version/\(flowLayoutVariant.versionId)/layout/\(flowLayoutVariant.id)/config/"
            }

        endpoint = HTTPEndpoint(
            method: .get,
            path: path
        )

        headers = HTTPHeaders()
            .setBuilderVersion(Adapty.uiBuilderVersion)
            .setBuilderConfigurationFormatVersion(Adapty.uiSchemaVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        self.logParams = logParams
    }
}

extension Backend.MainExecutor {
    func fetchFallbackUISchema(
        apiKeyPrefix: String,
        flowId: String,
        flowLayoutVariant: AdaptyFlow.LayoutVariant,
        flowLocale: String?,
        disableServerCache: Bool,
        decodingConfiguration: AdaptyUISchema.DecodingConfiguration
    ) async throws(HTTPError) -> (schema: AdaptyUISchema, data: Data) {
        let request = FetchFallbackUISchemaRequest(
            apiKeyPrefix: apiKeyPrefix,
            flowId: flowId,
            flowLayoutVariant: flowLayoutVariant,
            flowLocale: flowLocale,
            disableServerCache: disableServerCache,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "flow_id": flowId,
                "flow_version_id": flowLayoutVariant.versionId,
                "flow_layout_id": flowLayoutVariant.id,
                "flow_locale": flowLocale,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "disable_server_cache": disableServerCache,
            ]
        )

        let response: HTTPResponse<(schema: AdaptyUISchema, data: Data)> = try await perform(request, withDecoder: AdaptyUISchema.createDecoder(decodingConfiguration))
        return response.body
    }
}

//
//  FetchUISchemaRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.04.2026.
//

import AdaptyUIBuilder
import Foundation

struct FetchUISchemaRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp
    let requestName = BackendRequestName.fetchFallBackUISchema
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        flowId: String,
        viewConfigurationId: String,
        disableServerCache: Bool,
        logParams: EventParameters?
    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path:
            "sdk/in-apps/\(apiKeyPrefix)/flow/\(flowId)/version/\(viewConfigurationId)/config/"
        )

        headers = HTTPHeaders()
            .setBuilderVersion(Adapty.uiBuilderVersion)
            .setBuilderConfigurationFormatVersion(Adapty.uiSchemaVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        self.logParams = logParams
    }
}

extension AdaptyUISchema {
    static func decoder(
        _ response: HTTPDataResponse,
        _: HTTPCodableConfiguration?,
        _: HTTPRequest
    ) async throws -> HTTPResponse<AdaptyUISchema> {
        guard let data = response.body else { throw URLError(.cannotDecodeRawData) }
        let schema = try AdaptyUISchema(from: data)
        return response.replaceBody(schema)
    }
}

extension Backend.MainExecutor {
    func fetchFallbackUISchema(
        apiKeyPrefix: String,
        flowId: String,
        viewConfigurationId: String,
        disableServerCache: Bool
    ) async throws(HTTPError) -> AdaptyUISchema {
        let request = FetchUISchemaRequest(
            apiKeyPrefix: apiKeyPrefix,
            flowId: flowId,
            viewConfigurationId: viewConfigurationId,
            disableServerCache: disableServerCache,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "flow_id": flowId,
                "flow_version_id": viewConfigurationId,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "disable_server_cache": disableServerCache,
            ]
        )

        let response: HTTPResponse<AdaptyUISchema> = try await perform(request, withDecoder: AdaptyUISchema.decoder)
        return response.body
    }
}


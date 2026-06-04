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
        flowVersionId: String,
        flowLayoutId: String,
        disableServerCache: Bool,
        logParams: EventParameters?
    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path:
            "sdk/in-apps/\(apiKeyPrefix)/flow/\(flowId)/version/\(flowVersionId)/layout/\(flowLayoutId)/config/"
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
    ) async throws -> HTTPResponse<(schema: AdaptyUISchema, data: Data)> {
        guard let data = response.body else { throw URLError(.cannotDecodeRawData) }
        let schema = try AdaptyUISchema(from: data)
        return response.replaceBody((schema, data))
    }
}

extension Backend.MainExecutor {
    func fetchFallbackUISchema(
        apiKeyPrefix: String,
        flowId: String,
        flowVersionId: String,
        flowLayoutId: String,
        disableServerCache: Bool
    ) async throws(HTTPError) -> (schema: AdaptyUISchema, data: Data) {
        let request = FetchUISchemaRequest(
            apiKeyPrefix: apiKeyPrefix,
            flowId: flowId,
            flowVersionId: flowVersionId,
            flowLayoutId: flowLayoutId,
            disableServerCache: disableServerCache,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "flow_id": flowId,
                "flow_version_id": flowVersionId,
                "flow_layout_id": flowLayoutId,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "disable_server_cache": disableServerCache,
            ]
        )

        let response: HTTPResponse<(schema: AdaptyUISchema, data: Data)> = try await perform(request, withDecoder: AdaptyUISchema.decoder)
        return response.body
    }
}


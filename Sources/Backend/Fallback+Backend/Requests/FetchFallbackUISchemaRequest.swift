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
    let stamp = Log.stamp
    let requestName = BackendRequestName.fetchUISchema
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        flowId: String,
        flowVersionId: String,
        flowLayoutId: String,
        logParams: EventParameters
    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/flow/\(flowId)/version/\(flowVersionId)/layout/\(flowLayoutId)/\(Adapty.uiBuilderVersion)/config.json"
        )

        self.logParams = logParams
    }
}

extension Backend.FallbackExecutor {
    func fetchUISchema(
        apiKeyPrefix: String,
        flowId: String,
        flowVersionId: String,
        flowLayoutId: String,
        disableServerCache _: Bool
    ) async throws(HTTPError) -> (schema: AdaptyUISchema, data: Data) {
        let request = FetchFallbackUISchemaRequest(
            apiKeyPrefix: apiKeyPrefix,
            flowId: flowId,
            flowVersionId: flowVersionId,
            flowLayoutId: flowLayoutId,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "flow_id": flowId,
                "flow_version_id": flowVersionId,
                "flow_layout_Id": flowLayoutId,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_schema_version": Adapty.uiSchemaVersion,
            ]
        )

        let response: HTTPResponse<(schema: AdaptyUISchema, data: Data)> = try await perform(request, withDecoder: AdaptyUISchema.decoder)
        return response.body
    }
}


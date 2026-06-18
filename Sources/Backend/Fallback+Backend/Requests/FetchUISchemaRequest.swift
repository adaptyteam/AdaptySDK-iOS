//
//  FetchUISchemaRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import AdaptyUIBuilder
import Foundation

private struct FetchUISchemaRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let stamp = Log.stamp
    let requestName = BackendRequestName.fetchUISchema
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        flowId: String,
        flowLayout: AdaptyFlow.Layout,
        logParams: EventParameters
    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/flow/\(flowId)/version/\(flowLayout.versionId)/layout/\(flowLayout.id)/\(Adapty.uiBuilderVersion)/config.json"
        )

        self.logParams = logParams
    }
}

extension AdaptyUISchema {
    static func createDecoder(
        _ decodingConfiguration: AdaptyUISchema.DecodingConfiguration
    ) -> HTTPDecoder<(schema: AdaptyUISchema, data: Data)> {
        return decoder

        @Sendable
        func decoder(
            _ response: HTTPDataResponse,
            _: HTTPCodableConfiguration?,
            _: HTTPRequest
        ) async throws -> HTTPResponse<(schema: AdaptyUISchema, data: Data)> {
            guard let data = response.body else { throw URLError(.cannotDecodeRawData) }
            let schema = try AdaptyUISchema(from: data, configuration: decodingConfiguration)
            return response.replaceBody((schema, data))
        }
    }
}

extension Backend.FallbackExecutor {
    func fetchUISchema(
        apiKeyPrefix: String,
        flowId: String,
        flowLayout: AdaptyFlow.Layout,
        disableServerCache _: Bool,
        decodingConfiguration: AdaptyUISchema.DecodingConfiguration
    ) async throws(HTTPError) -> (schema: AdaptyUISchema, data: Data) {
        let request = FetchUISchemaRequest(
            apiKeyPrefix: apiKeyPrefix,
            flowId: flowId,
            flowLayout: flowLayout,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "flow_id": flowId,
                "flow_version_id": flowLayout.versionId,
                "flow_layout_id": flowLayout.id,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_schema_version": Adapty.uiSchemaVersion,
            ]
        )

        let response: HTTPResponse<(schema: AdaptyUISchema, data: Data)> = try await perform(request, withDecoder: AdaptyUISchema.createDecoder(decodingConfiguration))
        return response.body
    }
}


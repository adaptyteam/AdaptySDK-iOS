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
        flowLayoutVariant: AdaptyFlow.LayoutVariant,
        flowLocale: String?,
        logParams: EventParameters
    ) {
        let path =
            if let flowLocale {
                "/sdk/in-apps/\(apiKeyPrefix)/flow/\(flowId)/version/\(flowLayoutVariant.versionId)/layout/\(flowLayoutVariant.id)/\(flowLocale.base64URLEncoded)/\(Adapty.uiBuilderVersion)/config.json"
            } else {
                "/sdk/in-apps/\(apiKeyPrefix)/flow/\(flowId)/version/\(flowLayoutVariant.versionId)/layout/\(flowLayoutVariant.id)/\(Adapty.uiBuilderVersion)/config.json"
            }

        endpoint = HTTPEndpoint(
            method: .get,
            path: path
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
        flowLayoutVariant: AdaptyFlow.LayoutVariant,
        flowLocale: String?,
        disableServerCache _: Bool,
        decodingConfiguration: AdaptyUISchema.DecodingConfiguration
    ) async throws(HTTPError) -> (schema: AdaptyUISchema, data: Data) {
        let request = FetchUISchemaRequest(
            apiKeyPrefix: apiKeyPrefix,
            flowId: flowId,
            flowLayoutVariant: flowLayoutVariant,
            flowLocale: flowLocale,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "flow_id": flowId,
                "flow_version_id": flowLayoutVariant.versionId,
                "flow_layout_id": flowLayoutVariant.id,
                "flow_locale": flowLocale,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_schema_version": Adapty.uiSchemaVersion,
            ]
        )

        let response: HTTPResponse<(schema: AdaptyUISchema, data: Data)> = try await perform(request, withDecoder: AdaptyUISchema.createDecoder(decodingConfiguration))
        return response.body
    }
}

extension String {
    /// base64url (RFC 4648 §5) of UTF-8 bytes, no padding: path-safe for any characters.
    var base64URLEncoded: String {
        Data(utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

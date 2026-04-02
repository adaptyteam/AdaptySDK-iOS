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
    let requestName = BackendRequestName.fetchUISchema
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        flowVariationId: String,
        md5Hash: String,
        disableServerCache: Bool,
        logParams: EventParameters?
    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/flow/\(flowVariationId)/\(md5Hash)/"
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
        _ configuration: HTTPCodableConfiguration?,
        _: HTTPRequest
    ) async throws -> HTTPResponse<AdaptyUISchema> {
        let schema = try response.decodeBody(AdaptyUISchema.self, with: configuration)
        return response.replaceBody(schema)
    }
}

extension Backend.MainExecutor {
    func fetchUISchema(
        apiKeyPrefix: String,
        flowVariationId: String,
        disableServerCache: Bool
    ) async throws(HTTPError) -> AdaptyUISchema {
        let md5Hash = "{\"builder_version\":\"\(Adapty.uiBuilderVersion)\"}".md5.hexString

        let request = FetchUISchemaRequest(
            apiKeyPrefix: apiKeyPrefix,
            flowVariationId: flowVariationId,
            md5Hash: md5Hash,
            disableServerCache: disableServerCache,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "variation_id": flowVariationId,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        )

        let response: HTTPResponse<AdaptyUISchema> = try await perform(request, withDecoder: AdaptyUISchema.decoder)
        return response.body
    }
}


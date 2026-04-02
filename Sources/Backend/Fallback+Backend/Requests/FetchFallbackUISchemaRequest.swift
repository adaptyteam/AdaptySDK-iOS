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
        flowInstanceIdentity: String,
        disableServerCache: Bool,
        logParams: EventParameters

    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/flow/\(flowInstanceIdentity)/\(Adapty.uiBuilderVersion)/fallback.json"
        )

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        self.logParams = logParams
    }
}

extension Backend.FallbackExecutor {
    func fetchFallbackUISchema(
        apiKeyPrefix: String,
        flowInstanceIdentity: String,
        disableServerCache: Bool
    ) async throws(HTTPError) -> AdaptyUISchema {
        let request = FetchFallbackUISchemaRequest(
            apiKeyPrefix: apiKeyPrefix,
            flowInstanceIdentity: flowInstanceIdentity,
            disableServerCache: disableServerCache,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "flow_id": flowInstanceIdentity,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_schema_version": Adapty.uiSchemaVersion,
                "disable_server_cache": disableServerCache,
            ]
        )

        let response: HTTPResponse<AdaptyUISchema> = try await perform(request, withDecoder: AdaptyUISchema.decoder)
        return response.body
    }
}


//
//  FetchBackendStateRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.10.2022.
//
import Foundation

private struct FetchBackendStateRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let stamp = Log.stamp
    let requestName = BackendRequestName.fetchNetworkConfig

    init(apiKeyPrefix: String) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/company/\(apiKeyPrefix)/app/net-config.json"
        )
    }
}

private typealias ResponseBody = Backend.Response.Data<BackendState>

extension DefaultBackendExecutor {
    static func fetchBackendState(
        withBaseUrl baseUrl: URL,
        withSession session: HTTPSession,
        apiKeyPrefix: String
    ) async throws(HTTPError) -> BackendState {
        let request = FetchBackendStateRequest(
            apiKeyPrefix: apiKeyPrefix
        )

        let response: HTTPResponse<ResponseBody> = try await perform(
            request,
            withBaseUrl: baseUrl,
            withSession: session,
            withDecoder: HTTPDataResponse.defaultDecoder
        )

        return response.body.value
    }
}

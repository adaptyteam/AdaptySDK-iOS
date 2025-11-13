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
    let logName = APIRequestName.fetchNetworkConfig

    init(apiKeyPrefix: String) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/company/\(apiKeyPrefix)/app/net-config.json"
        )
    }
}

private typealias ResponseBody = Backend.Response.Data<BackendState>

extension Backend.StateExecutor {
    func fetchBackendState(
        apiKeyPrefix: String
    ) async throws(HTTPError) -> BackendState {
        let request = FetchBackendStateRequest(
            apiKeyPrefix: apiKeyPrefix
        )
        let response: HTTPResponse<ResponseBody> = try await perform(
            request,
            withBaseUrl: baseUrl
        )
        return response.body.value
    }
}

//
//  FetchNetworkConfigRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.10.2022.
//
import Foundation

private struct FetchNetworkConfigRequest: BackendRequest {
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

private typealias ResponseBody = Backend.Response.Data<NetworkConfiguration>

extension Backend.FallbackExecutor {
    func fetchNetworkConfig(
        apiKeyPrefix: String
    ) async throws(HTTPError) -> NetworkConfiguration {
        let request = FetchNetworkConfigRequest(
            apiKeyPrefix: apiKeyPrefix
        )
        let response: HTTPResponse<ResponseBody> = try await perform(request)
        return response.body.value
    }
}

//
//  FetchNetworkConfigRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.10.2022.
//
import Foundation

private struct FetchNetworkConfigRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Data<NetworkConfiguration>

    let endpoint: HTTPEndpoint
    let stamp = Log.stamp

    init(apiKeyPrefix: String) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/company/\(apiKeyPrefix)/app/net-config.json"
        )
    }
}

extension Backend.FallbackExecutor {
    func fetchNetworkConfig(
        apiKeyPrefix: String
    ) async throws(HTTPError) -> NetworkConfiguration {
        let request = FetchNetworkConfigRequest(
            apiKeyPrefix: apiKeyPrefix
        )

        let response = try await perform(
            request,
            requestName: .fetchNetworkConfig
        )
        return response.body.value
    }
}

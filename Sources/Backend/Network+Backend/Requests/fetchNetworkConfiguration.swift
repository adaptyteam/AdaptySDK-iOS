//
//  FetchNetworkConfigRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.10.2022.
//
import Foundation

private struct FetchNetworkConfigurationRequest: BackendRequest {
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

extension Backend.NetworkExecutor {
    func fetchNetworkConfiguration(
        apiKeyPrefix: String
    ) async throws(HTTPError) -> NetworkConfiguration {
        let request = FetchNetworkConfigurationRequest(
            apiKeyPrefix: apiKeyPrefix
        )
        let response: HTTPResponse<ResponseBody> = try await perform(
            request,
            withBaseUrl: baseUrl
        )
        return response.body.value
    }
}

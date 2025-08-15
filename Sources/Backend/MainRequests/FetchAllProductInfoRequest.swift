//
//  FetchAllProductInfoRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchAllProductInfoRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Data<[BackendProductInfo]>
    let endpoint: HTTPEndpoint
    let stamp = Log.stamp

    init(apiKeyPrefix: String) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/products/app_store/"
        )
    }
}

extension Backend.MainExecutor {
    func fetchProductInfo(
        apiKeyPrefix: String
    ) async throws(HTTPError) -> [BackendProductInfo] {
        let request = FetchAllProductInfoRequest(
            apiKeyPrefix: apiKeyPrefix
        )
        let response = try await perform(
            request,
            requestName: .fetchAllProductInfo
        )

        return response.body.value
    }
}

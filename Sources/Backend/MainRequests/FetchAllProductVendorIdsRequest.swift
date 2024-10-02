//
//  FetchAllProductVendorIdsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchAllProductVendorIdsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<[String]>
    let endpoint: HTTPEndpoint
    let stamp = Log.stamp

    init(apiKeyPrefix: String) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/products-ids/app_store/"
        )
    }
}

extension Backend.MainExecutor {
    func performFetchAllProductVendorIdsRequest(
        apiKeyPrefix: String
    ) async throws -> [String] {
        let request = FetchAllProductVendorIdsRequest(
            apiKeyPrefix: apiKeyPrefix
        )
        let response = try await perform(
            request,
            requestName: .fetchAllProductVendorIdsRequest
        )

        return response.body.value
    }
}

//
//  FetchAllProductVendorIdsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchAllProductVendorIdsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Data<[String]>
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
    func fetchAllProductVendorIds(
        apiKeyPrefix: String
    ) async throws -> [String] {
        let request = FetchAllProductVendorIdsRequest(
            apiKeyPrefix: apiKeyPrefix
        )
        let response = try await perform(
            request,
            requestName: .fetchAllProductVendorIds
        )

        return response.body.value
    }
}

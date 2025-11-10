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

extension Backend.DefaultExecutor {
    func fetchProductInfo(
        apiKeyPrefix: String,
        maxRetries: Int = 5
    ) async throws(HTTPError) -> [BackendProductInfo] {
        let request = FetchAllProductInfoRequest(
            apiKeyPrefix: apiKeyPrefix
        )
        var attempt = 0
        while !Task.isCancelled {
            do {
                let response = try await perform(
                    request,
                    requestName: .fetchAllProductInfo
                )
                return response.body.value
            } catch {
                guard attempt < maxRetries,
                      !error.isCancelled
                else {
                    throw error
                }
                attempt += 1
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            }
        }

        throw HTTPError.cancelled(request.endpoint)
    }
}

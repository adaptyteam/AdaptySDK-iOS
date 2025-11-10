//
//  HTTPDataResponse.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.08.2024
//

import Foundation

typealias HTTPDataResponse = HTTPResponse<Data?>

extension HTTPDataResponse {
    init(endpoint: HTTPEndpoint, response: HTTPURLResponse, metrics: HTTPMetrics?, data: Data?) {
        self.init(
            endpoint: endpoint,
            statusCode: response.statusCode,
            headers: HTTPHeaders(response.allHeaderFields),
            body: data,
            metrics: metrics
        )
    }
}

extension HTTPSession {
    func perform(_ request: some HTTPRequest, baseUrl: URL) async throws(HTTPError) -> HTTPDataResponse {
        try await perform(request, baseUrl: baseUrl) { @Sendable response in
            response
        }
    }
}

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

extension HTTPDataResponse {
    func decodeBody<T: Decodable & Sendable>(_ type: T.Type, with configuration: HTTPCodableConfiguration?) throws -> T {
        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)
        guard let data = body else { throw URLError(.cannotDecodeRawData) }
        return try jsonDecoder.decode(type, from: data)
    }
}

extension HTTPDataResponse {
    static func dataDecoder(
        _ response: HTTPDataResponse,
        _: HTTPCodableConfiguration?,
        _: HTTPRequest
    ) async throws -> HTTPDataResponse {
        response
    }
}

extension HTTPSession {
    func perform(_ request: some HTTPRequest, baseUrl: URL) async throws(HTTPError) -> HTTPDataResponse {
        try await perform(request, withBaseUrl: baseUrl, withDecoder: HTTPDataResponse.dataDecoder)
    }
}

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
        let body = try jsonDecoder.decode(type, from: data)
        return body
    }
}

extension HTTPDataResponse {
    static func defaultDecoder(
        _ response: HTTPDataResponse,
        _ configuration: HTTPCodableConfiguration?,
        _ request: HTTPRequest
    ) -> HTTPDataResponse { response }

    static func defaultDecoder<T: Decodable & Sendable>(
        _ response: HTTPDataResponse,
        _ configuration: HTTPCodableConfiguration?,
        _ request: HTTPRequest
    ) async throws -> HTTPResponse<T> {
        try response.replaceBody(response.decodeBody(T.self, with: configuration))
    }
}

extension HTTPSession {
    func perform(_ request: some HTTPRequest, baseUrl: URL) async throws(HTTPError) -> HTTPDataResponse {
        try await perform(request, withBaseUrl: baseUrl, withDecoder: HTTPDataResponse.defaultDecoder)
    }

    func perform<Body: Decodable & Sendable>(
        _ request: HTTPRequest,
        baseUrl: URL
    ) async throws(HTTPError) -> HTTPResponse<Body> {
        try await perform(request, withBaseUrl: baseUrl, withDecoder: HTTPDataResponse.defaultDecoder)
    }
}

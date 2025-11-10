//
//  HTTPRequestWithDecodableResponse.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 15.09.2022.
//

import Foundation

protocol HTTPRequestWithDecodableResponse: HTTPRequest {
    associatedtype ResponseBody: Decodable, Sendable

    func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration: HTTPCodableConfiguration?
    ) throws -> Response
}

extension HTTPRequestWithDecodableResponse {
    typealias Response = HTTPResponse<ResponseBody>

    func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?
    ) throws -> Response {
        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)
        let body = try jsonDecoder.decode(ResponseBody.self, responseBody: response.body)
        return response.replaceBody(body)
    }
}

extension HTTPSession {
    func perform<Request: HTTPRequestWithDecodableResponse>(
        _ request: Request,
        baseUrl: URL
    ) async throws(HTTPError) -> Request.Response {
        let configuration = configuration as? HTTPCodableConfiguration
        return try await perform(request, baseUrl: baseUrl) { @Sendable response in
            try request.decodeDataResponse(response, withConfiguration: configuration)
        }
    }
}

extension JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, responseBody data: Data?) throws -> T {
        guard let data else { throw URLError(.cannotDecodeRawData) }
        return try decode(type, from: data)
    }
}

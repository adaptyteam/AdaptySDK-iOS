//
//  HTTPEmptyResponse.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.08.2024
//
//

import Foundation

typealias HTTPEmptyResponse = HTTPResponse<Void>

extension HTTPResponse {
    var asHTTPEmptyResponse: HTTPEmptyResponse {
        self as? HTTPEmptyResponse ?? replaceBody(())
    }
}

extension HTTPEmptyResponse {
    static func defaultDecoder(
        _ response: HTTPDataResponse,
        _ configuration: HTTPCodableConfiguration?,
        _ request: HTTPRequest
    ) -> HTTPEmptyResponse {
        response.asHTTPEmptyResponse
    }
}

extension HTTPSession {
    func perform(_ request: some HTTPRequest, baseUrl: URL) async throws(HTTPError) -> HTTPEmptyResponse {
        try await perform(request, withBaseUrl: baseUrl, withDecoder: HTTPEmptyResponse.defaultDecoder)
    }
}

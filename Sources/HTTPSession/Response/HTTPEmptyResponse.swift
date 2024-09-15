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

extension HTTPSession {
    func perform(_ request: some HTTPRequest) async throws -> HTTPEmptyResponse {
        try await perform(request) { @Sendable response in
            response.asHTTPEmptyResponse
        }
    }
}

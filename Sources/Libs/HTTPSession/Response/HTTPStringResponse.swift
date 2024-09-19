//
//  HTTPStringResponse.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.08.2024
//

import Foundation

typealias HTTPStringResponse = HTTPResponse<String?>

extension HTTPDataResponse {
    var asHTTPStringResponse: HTTPStringResponse {
        replaceBody(body.flatMap { String(data: $0, encoding: .utf8) })
    }
}

extension HTTPSession {
    func perform(_ request: some HTTPRequest) async throws -> HTTPStringResponse {
        try await perform(request) { @Sendable response in
            response.asHTTPStringResponse
        }
    }
}

//
//  HTTPResponse.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2022.
//

import Foundation

typealias HTTPDataResponse = HTTPResponse<Data?>
typealias HTTPStringResponse = HTTPResponse<String?>
typealias HTTPEmptyResponse = HTTPResponse<Void>

// https://github.com/apple/swift-corelibs-foundation/issues/4338
typealias HTTPResponseHeaders = NSDictionary

struct HTTPResponse<Body> {
    let endpoint: HTTPEndpoint
    let statusCode: Int
    let headers: HTTPResponseHeaders
    let body: Body
}

extension HTTPResponse {
    var asEmptyResponse: HTTPEmptyResponse {
        self as? HTTPEmptyResponse ?? replaceBody(())
    }

    func replaceBody<NewBody>(_ newBody: NewBody) -> HTTPResponse<NewBody> {
        HTTPResponse<NewBody>(endpoint: endpoint, statusCode: statusCode, headers: headers, body: newBody)
    }
}

extension HTTPStringResponse {
    init(endpoint: HTTPEndpoint, response: HTTPURLResponse, string: String?) {
        self.init(endpoint: endpoint, statusCode: response.statusCode, headers: response.allHeaderFields as HTTPResponseHeaders, body: string)
    }
}

extension HTTPDataResponse {
    init(endpoint: HTTPEndpoint, response: HTTPURLResponse, data: Data?) {
        self.init(endpoint: endpoint, statusCode: response.statusCode, headers: response.allHeaderFields as HTTPResponseHeaders, body: data)
    }
}

extension HTTPEmptyResponse {
    init(endpoint: HTTPEndpoint, statusCode: Int, headers: HTTPResponseHeaders) {
        self.init(endpoint: endpoint, statusCode: statusCode, headers: headers, body: ())
    }
}

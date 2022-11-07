//
//  HTTPResponse.swift
//  Adapty
//
//  Created by Aleksei Valiano on 22.09.2022.
//

import Foundation

typealias HTTPDataResponse = HTTPResponse<Data?>
typealias HTTPStringResponse = HTTPResponse<String?>
typealias HTTPEmptyResponse = HTTPResponse<Void>

struct HTTPResponse<Body> {
    typealias Headers = [AnyHashable: Any]

    let endpoint: HTTPEndpoint
    let statusCode: Int
    let headers: Headers
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
        self.init(endpoint: endpoint, statusCode: response.statusCode, headers: response.allHeaderFields, body: string)
    }
}

extension HTTPDataResponse {
    init(endpoint: HTTPEndpoint, response: HTTPURLResponse, data: Data?) {
        self.init(endpoint: endpoint, statusCode: response.statusCode, headers: response.allHeaderFields, body: data)
    }
}

extension HTTPEmptyResponse {
    init(endpoint: HTTPEndpoint, statusCode: Int, headers: Headers) {
        self.init(endpoint: endpoint, statusCode: statusCode, headers: headers, body: ())
    }
}

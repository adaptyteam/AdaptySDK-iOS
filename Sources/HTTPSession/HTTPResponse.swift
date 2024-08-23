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

typealias HTTPResponseHeaders = [String: any Sendable]

struct HTTPResponse<Body: Sendable>: Sendable {
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

extension HTTPDataResponse {
    init(endpoint: HTTPEndpoint, response: HTTPURLResponse, data: Data?) {
        self.init(endpoint: endpoint, statusCode: response.statusCode, headers: response.allHeaderFields.asHTTPResponseHeaders, body: data)
    }
}

private extension [AnyHashable: Any] {
    var asHTTPResponseHeaders: HTTPResponseHeaders {
        let array: [(String, any Sendable)] = self.compactMap { key, value in
            guard let key = key as? String else { return nil }
            return (key, value)
        }
        return HTTPResponseHeaders(array) { $1 }
    }
}

extension HTTPResponseHeaders {
    func value(forHTTPHeaderField field: String) -> any Sendable {
        let header = self.first { key, _ in
            key.caseInsensitiveCompare(field) == .orderedSame
        }
        return header.map(\.value)
    }
}

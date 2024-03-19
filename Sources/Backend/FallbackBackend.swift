//
//  FallbackBackend.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

struct FallbackBackend: HTTPCodableConfiguration {
    let baseURL: URL
    let sessionConfiguration: URLSessionConfiguration

    func configure(decoder: JSONDecoder) { Backend.configure(decoder: decoder) }
    func configure(encoder: JSONEncoder) { Backend.configure(encoder: encoder) }

    init(secretKey _: String, baseURL url: URL, withProxy: (host: String, port: Int)? = nil) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        if let (host, port) = withProxy {
            configuration.connectionProxyDictionary = [
                String(kCFNetworkProxiesHTTPEnable): NSNumber(value: 1),
                String(kCFNetworkProxiesHTTPProxy): host,
                String(kCFNetworkProxiesHTTPPort): port,
            ]
        }
        baseURL = url
        sessionConfiguration = configuration
    }
}

extension FallbackBackend {
    func createHTTPSession(
        responseQueue: DispatchQueue,
        errorHandler: ((HTTPError) -> Void)? = nil
    ) -> HTTPSession {
        HTTPSession(
            configuration: self,
            responseQueue: responseQueue,
            requestAdditional: nil,
            responseValidator: validator,
            errorHandler: errorHandler
        )
    }

    func validator(_ response: HTTPDataResponse) -> HTTPError? {
        HTTPResponse.statusCodeValidator(response)
    }
}

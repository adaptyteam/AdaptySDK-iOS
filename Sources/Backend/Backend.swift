//
//  Backend.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

struct Backend: HTTPCodableConfiguration {
    let baseURL: URL
    let sessionConfiguration: URLSessionConfiguration
    let fallback: FallbackBackend
    let configs: FallbackBackend

    let defaultEncodedContentType = "application/vnd.api+json"

    func configure(decoder: JSONDecoder) { Backend.configure(decoder: decoder) }
    func configure(encoder: JSONEncoder) { Backend.configure(encoder: encoder) }

    init(
        secretKey: String,
        baseURL: URL,
        baseFallbackURL:URL,
        baseConfigsURL: URL,
        withProxy: (host: String, port: Int)? = nil
    ) {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Request.globalHeaders(secretKey: secretKey)
        configuration.timeoutIntervalForRequest = 30
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        if let (host, port) = withProxy {
            configuration.connectionProxyDictionary = [
                String(kCFNetworkProxiesHTTPEnable): NSNumber(value: 1),
                String(kCFNetworkProxiesHTTPProxy): host,
                String(kCFNetworkProxiesHTTPPort): port,
            ]
        }
        self.baseURL = baseURL
        sessionConfiguration = configuration
        self.fallback =  FallbackBackend(secretKey:secretKey, baseURL: baseFallbackURL, withProxy: withProxy)
        self.configs =  FallbackBackend(secretKey:secretKey, baseURL: baseConfigsURL, withProxy: withProxy)
    }
}

extension Backend {
    enum Request {}
    enum Response {}

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
}

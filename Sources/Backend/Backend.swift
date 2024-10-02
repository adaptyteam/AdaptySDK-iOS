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

    func configure(jsonDecoder: JSONDecoder) { Backend.configure(jsonDecoder: jsonDecoder) }
    func configure(jsonEncoder: JSONEncoder) { Backend.configure(jsonEncoder: jsonEncoder) }

    init(with configuration: Adapty.Configuration, envorinment: Environment) {
        let baseUrls = configuration.backend
        let apiKey = configuration.apiKey

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpAdditionalHeaders = Request.globalHeaders(  configuration,  envorinment  )
        sessionConfiguration.timeoutIntervalForRequest = 30
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData

        if let (host, port) = baseUrls.proxy {
            sessionConfiguration.connectionProxyDictionary = [
                String(kCFNetworkProxiesHTTPEnable): NSNumber(value: 1),
                String(kCFNetworkProxiesHTTPProxy): host,
                String(kCFNetworkProxiesHTTPPort): port,
            ]
        }

        self.sessionConfiguration = sessionConfiguration

        self.baseURL = baseUrls.baseUrl

        self.fallback = FallbackBackend(
            apiKey: apiKey,
            baseURL: baseUrls.fallbackUrl,
            withProxy: baseUrls.proxy
        )

        self.configs = FallbackBackend(
            apiKey: apiKey,
            baseURL: baseUrls.configsUrl,
            withProxy: baseUrls.proxy
        )
    }
}

extension Backend {
    enum Request {}
    enum Response {}
}

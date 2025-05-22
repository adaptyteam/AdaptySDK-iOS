//
//  Backend.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

package struct Backend: HTTPCodableConfiguration {
    let baseURL: URL
    let sessionConfiguration: URLSessionConfiguration
    let fallback: RemoteFilesBackend
    let configs: RemoteFilesBackend

    let defaultEncodedContentType = "application/vnd.api+json"

    func configure(jsonDecoder: JSONDecoder) { Backend.configure(jsonDecoder: jsonDecoder) }
    func configure(jsonEncoder: JSONEncoder) { Backend.configure(jsonEncoder: jsonEncoder) }

    init(with configuration: AdaptyConfiguration, environment: Environment) {
        let baseUrls = configuration.backend
        let apiKey = configuration.apiKey

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpAdditionalHeaders = Request.globalHeaders(configuration, environment)
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

        self.fallback = RemoteFilesBackend(
            apiKey: apiKey,
            baseURL: baseUrls.fallbackUrl,
            withProxy: baseUrls.proxy
        )

        self.configs = RemoteFilesBackend(
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

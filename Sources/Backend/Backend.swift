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
    let ua: UABackend

    let defaultEncodedContentType = "application/vnd.api+json"

    func configure(jsonDecoder: JSONDecoder) { Backend.configure(jsonDecoder: jsonDecoder) }
    func configure(jsonEncoder: JSONEncoder) { Backend.configure(jsonEncoder: jsonEncoder) }

    init(with configuration: AdaptyConfiguration, environment: Environment) {
        let backend = configuration.backend

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpAdditionalHeaders = Request.globalHeadersWithStoreKit(configuration, environment)
        sessionConfiguration.timeoutIntervalForRequest = 30
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.protocolClasses = (backend.protocolClasses ?? []) + (sessionConfiguration.protocolClasses ?? [])

        if let (host, port) = backend.proxy {
            sessionConfiguration.connectionProxyDictionary = [
                String(kCFNetworkProxiesHTTPEnable): NSNumber(value: 1),
                String(kCFNetworkProxiesHTTPProxy): host,
                String(kCFNetworkProxiesHTTPPort): port,
            ]
        }

        self.sessionConfiguration = sessionConfiguration

        self.baseURL = backend.mainBaseUrl

        self.fallback = RemoteFilesBackend(
            with: configuration,
            baseURL: backend.fallbackBaseUrl
        )

        self.configs = RemoteFilesBackend(
            with: configuration,
            baseURL: backend.configsBaseUrl
        )

        self.ua = UABackend(
            with: configuration,
            environment: environment
        )
    }
}

extension Backend {
    enum Request {}
    enum Response {}
}

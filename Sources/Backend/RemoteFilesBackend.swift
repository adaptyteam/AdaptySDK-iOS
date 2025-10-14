//
//  RemoteFilesBackend.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

struct RemoteFilesBackend: HTTPCodableConfiguration {
    let baseURL: URL
    let sessionConfiguration: URLSessionConfiguration

    func configure(jsonDecoder: JSONDecoder) { Backend.configure(jsonDecoder: jsonDecoder) }
    func configure(jsonEncoder: JSONEncoder) { Backend.configure(jsonEncoder: jsonEncoder) }

    init(with configuration: AdaptyConfiguration, baseURL url: URL) {
        let backend = configuration.backend

        let sessionConfiguration = URLSessionConfiguration.default
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

        self.baseURL = true ?  backend.fallbackBaseUrl : backend.configsBaseUrl
        self.sessionConfiguration = sessionConfiguration
    }
}

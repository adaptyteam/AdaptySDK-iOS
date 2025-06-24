//
//  UABackend.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 09.06.2025.
//

import Foundation

struct UABackend: HTTPCodableConfiguration {
    let baseURL: URL
    let sessionConfiguration: URLSessionConfiguration

    let defaultEncodedContentType = "application/json"

    func configure(jsonDecoder: JSONDecoder) { Backend.configure(jsonDecoder: jsonDecoder) }
    func configure(jsonEncoder: JSONEncoder) { Backend.configure(jsonEncoder: jsonEncoder) }

    init(with configuration: AdaptyConfiguration, environment: Environment) {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpAdditionalHeaders = Backend.Request.globalHeaders(configuration, environment)
        sessionConfiguration.timeoutIntervalForRequest = 30
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData

        if let (host, port) = configuration.backend.proxy {
            sessionConfiguration.connectionProxyDictionary = [
                String(kCFNetworkProxiesHTTPEnable): NSNumber(value: 1),
                String(kCFNetworkProxiesHTTPProxy): host,
                String(kCFNetworkProxiesHTTPPort): port,
            ]
        }

        self.sessionConfiguration = sessionConfiguration
        self.baseURL = configuration.backend.uaUrl
    }
}

extension UABackend {
    static func canRetryRequest(_ error: HTTPError) -> Bool {
        switch error {
        case .perform:
            false
        case let .network(_, _, _, error: error):
            (error as NSError).isNetworkConnectionError
        case let .decoding(_, _, statusCode, _, _, _),
             let .backend(_, _, statusCode, _, _, _):
            switch statusCode {
            case 429, 499, 500 ... 599:
                true
            case 400 ... 499:
                false
            default:
                true
            }
        }
    }
}

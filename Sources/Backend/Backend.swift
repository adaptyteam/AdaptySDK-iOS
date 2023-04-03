//
//  Backend.swift
//  Adapty
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

struct Backend: HTTPCodableConfiguration {
    static let publicEnvironmentBaseUrl = URL(string: "https://api.adapty.io/api/v1")!

    let baseURL: URL
    let sessionConfiguration: URLSessionConfiguration

    init(secretKey: String, baseURL url: URL = publicEnvironmentBaseUrl, withProxy: (host: String, port: Int)? = nil) {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Request.globalHeaders(secretKey: secretKey)
        configuration.timeoutIntervalForRequest = 30
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
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

    func createHTTPSession(responseQueue: DispatchQueue,
                           errorHandler: ((HTTPError) -> Void)? = nil) -> HTTPSession {
        HTTPSession(configuration: self,
                    responseQueue: responseQueue,
                    requestAdditionals: nil,
                    responseValidator: validator,
                    errorHandler: errorHandler)
    }

    let defaultEncodedContentType = "application/vnd.api+json"

    func configure(decoder: JSONDecoder) { Backend.configure(decoder: decoder) }
    func configure(encoder: JSONEncoder) { Backend.configure(encoder: encoder) }

    static func configure(decoder: JSONDecoder) {
        decoder.dateDecodingStrategy = .formatted(Backend.dateFormatter)
        decoder.dataDecodingStrategy = .base64
    }

    static func configure(encoder: JSONEncoder) {
        encoder.dateEncodingStrategy = .formatted(Backend.dateFormatter)
        encoder.dataEncodingStrategy = .base64
    }

    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        configure(decoder: decoder)
        return decoder
    }

    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        configure(encoder: encoder)
        return encoder
    }

    enum Request {}
    enum Response {}
}

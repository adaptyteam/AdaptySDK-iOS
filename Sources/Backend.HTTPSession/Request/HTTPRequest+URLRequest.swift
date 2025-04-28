//
//  HTTPRequest+URLRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.08.2024
//

import Foundation

private enum HeaderKey {
    static let contentType: String = "Content-Type"
}

extension HTTPRequest {
    func convertToURLRequest(configuration: HTTPConfiguration, additional: HTTPRequestAdditional?) throws -> URLRequest {
        let preUrl = configuration.baseURL.appendingPathComponent(endpoint.path)

        guard var urlComponents = URLComponents(url: preUrl, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }

        var queryItems = self.queryItems
        if let additionalQueryItems = additional?.queryItems {
            queryItems.append(contentsOf: additionalQueryItems)
        }

        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(
            url: url,
            cachePolicy: cachePolicy ?? .useProtocolCachePolicy,
            timeoutInterval: timeoutInterval ?? 60.0
        )

        request.httpMethod = endpoint.method.rawValue

        headers.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }

        additional?.headers?.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }

        if let dataRequest = self as? HTTPDataRequest {
            let httpBody = try dataRequest.getData(configuration: configuration)
            request.httpBody = httpBody

            if let contentType = dataRequest.contentType
                ?? (configuration as? HTTPCodableConfiguration)?.defaultEncodedContentType,
                request.value(forHTTPHeaderField: HeaderKey.contentType)?.isEmpty ?? true
            {
                request.setValue(contentType, forHTTPHeaderField: HeaderKey.contentType)
            }
        }

        return request
    }
}

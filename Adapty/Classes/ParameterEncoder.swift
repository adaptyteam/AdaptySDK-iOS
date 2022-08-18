//
//  ParameterEncoder.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]

extension Parameters {
    enum TypeNames: String {
        case profile = "adapty_analytics_profile"
        case installation = "adapty_analytics_profile_installation_meta"
        case appleReceipt = "adapty_inapps_apple_receipt_validation_result"
        case appleSubscriptionOffer = "adapty_inapps_apple_subscription_offer_signing_result"
        case profileAttribution = "adapty_analytics_profile_attribution"
        case profileAnalytics = "adapty_analytics_profile_analytics_enabled"
        case transactionVariationId = "adapty_analytics_transaction_variation_id"
    }

    static func formatData(with id: Any, type: TypeNames, attributes: Parameters) -> Parameters {
        var data = ["id": id, "type": type.rawValue]
        if attributes.count > 0 {
            data["attributes"] = attributes
        }
        return ["data": data]
    }

    func attributes() throws -> Parameters {
        guard let json = self as? Parameters else {
            throw AdaptyError.invalidProperty("JSON response", self)
        }

        guard var attributes = json["attributes"] as? Parameters else {
            throw AdaptyError.missingParam("JSON response - attributes")
        }

        if let id = json["id"] as? String {
            attributes["id"] = id
        }

        return attributes
    }
}

protocol ParameterEncoder {
    func encode(_ urlRequest: URLRequest, with parameters: Parameters) throws -> URLRequest
}

struct JSONParameterEncoder: ParameterEncoder {
    func encode(_ urlRequest: URLRequest, with parameters: Parameters) throws -> URLRequest {
        var urlRequest = urlRequest
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonAsData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw AdaptyError.encodingFailed
        }

        return urlRequest
    }
}

struct URLParameterEncoder: ParameterEncoder {
    func encode(_ urlRequest: URLRequest, with parameters: Parameters) throws -> URLRequest {
        var urlRequest = urlRequest

        guard let url = urlRequest.url else { throw AdaptyError.missingURL }

        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            urlComponents.queryItems = [URLQueryItem]()

            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }
}

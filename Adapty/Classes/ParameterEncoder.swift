//
//  ParameterEncoder.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]

enum EncoderError : String, Error {
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
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
            throw EncoderError.encodingFailed
        }
        
        return urlRequest
    }
}

struct URLParameterEncoder: ParameterEncoder {
    func encode(_ urlRequest: URLRequest, with parameters: Parameters) throws -> URLRequest {
        var urlRequest = urlRequest
        
        guard let url = urlRequest.url else { throw EncoderError.missingURL }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key,value) in parameters {
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

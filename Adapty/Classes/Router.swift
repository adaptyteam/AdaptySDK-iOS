//
//  Router.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation

enum Router {
    
    case createProfile(Parameters)
    case updateProfile(id: String, params: Parameters)
    case syncInstallation(params: Parameters)
    case validateReceipt(params: Parameters)
    case trackEvent(params: Parameters)
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        switch self {
        case .trackEvent:
            return "kinesis.us-east-1.amazonaws.com"
        default:
            return "api-dev.adapty.io/api"
        }
    }
    
    var stage: String {
        switch self {
        case .trackEvent:
            return ""
        default:
            return "/v1"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createProfile,
             .syncInstallation,
             .validateReceipt,
             .trackEvent:
            return .post
        case .updateProfile:
            return .patch
        }
    }
    
    var path: String {
        switch self {
        case .createProfile:
            return "/sdk/analytics/profile/"
        case .updateProfile(let id, _):
            return "/sdk/analytics/profile/\(id)/"
        case .syncInstallation:
            return "/sdk/analytics/profile/installation/meta/sync/"
        case .validateReceipt:
            return "/sdk/in-apps/apple/validate/"
        case .trackEvent:
            return ""
        }
    }
    
    var keyPath: String? {
        switch self {
        case .validateReceipt:
            return nil
        default:
            return "data"
        }
    }

    var authorizationHeader: (key: String, value: String)? {
        switch self {
        case .trackEvent:
            return nil
        default:
            return ("Authorization", "Api-Key \(Constants.APIKeys.secretKey)")
        }
    }
    
    func asURLRequest() throws -> URLRequest {

        var request = URLRequest(url: URL(string: "\(scheme)://\(host)\(stage)\(path)")!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        if let authorizationHeader = authorizationHeader {
            request.setValue(authorizationHeader.value, forHTTPHeaderField: authorizationHeader.key)
        }
        request.httpMethod = method.rawValue
        
        var requestParams: Parameters = [:]
        
        switch self {
        case .createProfile(let params),
             .updateProfile(_, let params),
             .syncInstallation(let params),
             .validateReceipt(let params),
             .trackEvent(let params):
            requestParams = params
        }
        
        if self.method == .get {
            request = try URLParameterEncoder().encode(request, with: requestParams)
        } else {
            request = try JSONParameterEncoder().encode(request, with: requestParams)
        }
        
        return request
    }
    
}

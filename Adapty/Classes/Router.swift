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
    case createInstallation(params: Parameters)
    case updateInstallation(id: String, params: Parameters)
    case validateReceipt(params: Parameters)
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        return "api-dev.adapty.io/api"
    }
    
    var stage: String {
        return "v1"
    }
    
    var method: HTTPMethod {
        switch self {
        case .createProfile,
             .createInstallation,
             .validateReceipt:
            return .post
        case .updateProfile,
             .updateInstallation:
            return .patch
        }
    }
    
    var path: String {
        switch self {
        case .createProfile:
            return "/sdk/analytics/profile/"
        case .updateProfile(let id, _):
            return "/sdk/analytics/profile/\(id)/"
        case .createInstallation:
            return "/sdk/analytics/profile/installation/meta/"
        case .updateInstallation(let id, _):
            return "/sdk/analytics/profile/installation/meta/\(id)/"
        case .validateReceipt:
            return "/sdk/in-apps/apple/validate/"
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
    
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: URL(string: "\(scheme)://\(host)/\(stage)\(path)")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.setValue("Api-Key \(Constants.APIKeys.secretKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = method.rawValue
        
        var requestParams: Parameters = [:]
        
        switch self {
        case .createProfile(let params),
             .updateProfile(_, let params),
             .createInstallation(let params),
             .updateInstallation(_, let params),
             .validateReceipt(let params):
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

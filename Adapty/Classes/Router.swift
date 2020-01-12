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
    case getPurchaseContainers
    case signSubscriptionOffer(params: Parameters)
    
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
        case .getPurchaseContainers,
             .signSubscriptionOffer:
            return .get
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
        case .getPurchaseContainers:
            return "/sdk/in-apps/purchase-container/"
        case .signSubscriptionOffer:
            return "/sdk/in-apps/apple/subscription/offer/sign/"
        }
    }
    
    var keyPath: String? {
        switch self {
        case .validateReceipt,
             .getPurchaseContainers:
            return nil
        default:
            return "data"
        }
    }

    var authorizationHeader: String? {
        switch self {
        case .trackEvent:
            return nil
        default:
            return "Api-Key \(Constants.APIKeys.secretKey)"
        }
    }
    
    func asURLRequest() throws -> URLRequest {

        var request = URLRequest(url: URL(string: "\(scheme)://\(host)\(stage)\(path)")!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        if let authorizationHeader = authorizationHeader {
            request.setValue(authorizationHeader, forHTTPHeaderField: Constants.Headers.authorization)
        }
        if let profileId = DefaultsManager.shared.profile?.profileId {
            request.setValue(profileId, forHTTPHeaderField: Constants.Headers.profileId)
        } else {
            request.setValue(UserProperties.staticUuid, forHTTPHeaderField: Constants.Headers.profileId)
        }

        request.httpMethod = method.rawValue
        
        var requestParams: Parameters = [:]
        
        switch self {
        case .createProfile(let params),
             .updateProfile(_, let params),
             .syncInstallation(let params),
             .validateReceipt(let params),
             .trackEvent(let params),
             .signSubscriptionOffer(let params):
            requestParams = params
        case .getPurchaseContainers:
            break
        }
        
        if self.method == .get {
            request = try URLParameterEncoder().encode(request, with: requestParams)
        } else {
            request = try JSONParameterEncoder().encode(request, with: requestParams)
        }
        
        return request
    }
    
}

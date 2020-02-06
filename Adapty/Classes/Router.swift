//
//  Router.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

enum Router {
    
    case createProfile(id: String, params: Parameters)
    case updateProfile(id: String, params: Parameters)
    case syncInstallation(id: String, profileId: String, params: Parameters)
    case validateReceipt(params: Parameters)
    case trackEvent(params: Parameters)
    case getPurchaseContainers(params: Parameters)
    case signSubscriptionOffer(params: Parameters)
    case getPurchaserInfo(id: String)
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        switch self {
        case .trackEvent:
            return "kinesis.us-east-1.amazonaws.com"
        default:
            return "api.adapty.io/api"
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
             .signSubscriptionOffer,
             .getPurchaserInfo:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .createProfile(let id, _),
             .updateProfile(let id, _),
             .getPurchaserInfo(let id):
            return "/sdk/analytics/profiles/\(id)/"
        case .syncInstallation(let id, let profileId, _):
            return "/sdk/analytics/profiles/\(profileId)/installation-metas/\(id)/"
        case .validateReceipt:
            return "/sdk/in-apps/apple/receipt/validate/"
        case .trackEvent:
            return ""
        case .getPurchaseContainers:
            return "/sdk/in-apps/purchase-containers/"
        case .signSubscriptionOffer:
            return "/sdk/in-apps/apple/subscription-offer/sign/"
        }
    }
    
    var keyPath: String? {
        switch self {
        case .validateReceipt,
             .trackEvent,
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
        request.setValue("iOS", forHTTPHeaderField: Constants.Headers.platform)

        request.httpMethod = method.rawValue
        
        var requestParams: Parameters = [:]
        
        switch self {
        case .createProfile(_, let params),
             .updateProfile(_, let params),
             .syncInstallation(_, _, let params),
             .validateReceipt(let params),
             .trackEvent(let params),
             .signSubscriptionOffer(let params),
             .getPurchaseContainers(let params):
            requestParams = params
        case .getPurchaserInfo:
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

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
    case getPaywalls(params: Parameters)
    case signSubscriptionOffer(params: Parameters)
    case getPurchaserInfo(id: String)
    case updateAttribution(id: String, params: Parameters)
    case getPromo(id: String)
    case enableAnalytics(id: String, params: Parameters)
    case setTransactionVariationId(params: Parameters)
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        switch self {
        case .trackEvent:
            return Constants.URLs.kinesis
        default:
            return Constants.URLs.api
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
             .trackEvent,
             .updateAttribution,
             .enableAnalytics,
             .setTransactionVariationId:
            return .post
        case .updateProfile:
            return .patch
        case .getPaywalls,
             .signSubscriptionOffer,
             .getPurchaserInfo,
             .getPromo:
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
        case .getPaywalls:
            return "/sdk/in-apps/purchase-containers/"
        case .signSubscriptionOffer:
            return "/sdk/in-apps/apple/subscription-offer/sign/"
        case .updateAttribution(let id, _):
            return "/sdk/analytics/profiles/\(id)/attribution/"
        case .getPromo(let id):
            return "/sdk/analytics/profiles/\(id)/promo/"
        case .enableAnalytics(let id, _):
            return "/sdk/analytics/profiles/\(id)/analytics-enabled/"
        case .setTransactionVariationId:
            return "/sdk/in-apps/transaction-variation-id/"
        }
    }
    
    var keyPath: String? {
        switch self {
        case .trackEvent,
             .getPaywalls:
            return nil
        default:
            return "data"
        }
    }
    
    var timeoutInterval: TimeInterval {
        switch self {
        case .getPaywalls:
            if DefaultsManager.shared.cachedPaywalls != nil { return 10 }
            else { break }
        default:
            break
        }
        
        return 30
    }

    var authorizationHeader: String {
        return "Api-Key \(Constants.APIKeys.secretKey)"
    }
    
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: requestURL,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        
        requestHeaders.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }

        request.httpMethod = method.rawValue
        
        if self.method == .get {
            request = try URLParameterEncoder().encode(request, with: requestParams)
        } else {
            request = try JSONParameterEncoder().encode(request, with: requestParams)
        }
        
        RequestHashManager.shared.tryToAddHashHeader(for: self, in: &request)
                
        return request
    }
    
    private var requestParams: Parameters {
        switch self {
        case .createProfile(_, let params),
             .updateProfile(_, let params),
             .syncInstallation(_, _, let params),
             .validateReceipt(let params),
             .trackEvent(let params),
             .signSubscriptionOffer(let params),
             .getPaywalls(let params),
             .updateAttribution(_, let params),
             .enableAnalytics(_, let params),
             .setTransactionVariationId(let params):
            return params
        case .getPurchaserInfo,
             .getPromo:
            return [:]
        }
    }
    
    private var requestURL: URL {
        return URL(string: "\(scheme)://\(host)\(stage)\(path)")!
    }
    
    private var requestHeaders: [String: String?] {
        var headers = [String: String?]()
        switch self {
        case .trackEvent:
            break
        default:
            headers[Constants.Headers.authorization] = authorizationHeader
            headers[Constants.Headers.profileId] = DefaultsManager.shared.profileId
            headers[Constants.Headers.platform] = UserProperties.platform
            headers[Constants.Headers.version] = UserProperties.sdkVersion
            headers[Constants.Headers.build] = String(UserProperties.sdkVersionBuild)
            headers[Constants.Headers.locale] = String(UserProperties.locale)
        }
        return headers
    }
}

extension Router {
    
    func logRequestStart() {
        let message = """
        Starting new request: \(self.method.rawValue.uppercased()) \(requestURL)
        Params: \(requestParams)
        Headers: \(requestHeaders.compactMapValues({ $0 }))
        """
        logMessage(message)
    }

    func logRequestRetry() {
        let message = """
        Retry request: \(self.method.rawValue.uppercased()) \(requestURL)
        """
        logMessage(message)
    }

    private func logMessage(_ message: String) {
        switch self {
        case .trackEvent:
            LoggerManager.logGlobalMessage(message)
        default:
            LoggerManager.logMessage(message)
        }
    }
}

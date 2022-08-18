//
//  Router.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

enum API {
    // ApiKey will be replaced during SDK active method
    static var secretKey = ""
    
    enum URLs {
        static let api = "api.adapty.io/api"
        static let kinesis = "kinesis.us-east-1.amazonaws.com"
    }
    
    enum Headers {
        static let authorization = "Authorization"
        static let profileId = "ADAPTY-SDK-PROFILE-ID"
        static let platform = "ADAPTY-SDK-PLATFORM"
        static let version = "ADAPTY-SDK-VERSION"
        static let build = "ADAPTY-SDK-VERSION-BUILD"
        static let locale = "ADAPTY_SDK_LOCALE"
        static let previousResponseHash = "ADAPTY-SDK-PREVIOUS-RESPONSE-HASH"
        static let xResponseHash = "x-response-hash"
    }
}

enum Router {
    case createProfile(id: String, params: Parameters)
    case updateProfile(id: String, params: Parameters)
    case syncInstallation(id: String, profileId: String, params: Parameters)
    case validateReceipt(params: Parameters)
    case trackEvent(params: Parameters)
    case getPaywall(id: String, params: Parameters)
    case getProducts(params: Parameters)
    case signSubscriptionOffer(params: Parameters)
    case getPurchaserInfo(id: String)
    case updateAttribution(id: String, params: Parameters)
    case enableAnalytics(id: String, params: Parameters)
    case setTransactionVariationId(params: Parameters)

    var scheme: String {
        return "https"
    }

    var host: String {
        switch self {
        case .trackEvent:
            return API.URLs.kinesis
        default:
            return API.URLs.api
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
        case .getPaywall,
             .getProducts,
             .signSubscriptionOffer,
             .getPurchaserInfo:
            return .get
        }
    }

    var path: String {
        switch self {
        case let .createProfile(id, _),
             let .updateProfile(id, _),
             let .getPurchaserInfo(id):
            return "/sdk/analytics/profiles/\(id)/"
        case let .syncInstallation(id, profileId, _):
            return "/sdk/analytics/profiles/\(profileId)/installation-metas/\(id)/"
        case .validateReceipt:
            return "/sdk/in-apps/apple/receipt/validate/"
        case .trackEvent:
            return ""
        case let .getPaywall(id, _):
            return "/sdk/in-apps/purchase-containers/\(id)/"
        case .getProducts:
            return "/sdk/in-apps/purchase-products/"
        case .signSubscriptionOffer:
            return "/sdk/in-apps/apple/subscription-offer/sign/"
        case let .updateAttribution(id, _):
            return "/sdk/analytics/profiles/\(id)/attribution/"
        case let .enableAnalytics(id, _):
            return "/sdk/analytics/profiles/\(id)/analytics-enabled/"
        case .setTransactionVariationId:
            return "/sdk/in-apps/transaction-variation-id/"
        }
    }

    var keyPath: String? {
        switch self {
        case .trackEvent,
             .getProducts:
            return nil
        default:
            return "data"
        }
    }

    var timeoutInterval: TimeInterval {
        switch self {
        case .getProducts:
            if DefaultsManager.shared.cachedProducts != nil { return 10 }
            else { break }
        default:
            break
        }

        return 30
    }

    var authorizationHeader: String {
        return "Api-Key \(API.secretKey)"
    }

    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: requestURL,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)

        requestHeaders.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }

        request.httpMethod = method.rawValue

        if method == .get {
            request = try URLParameterEncoder().encode(request, with: requestParams)
        } else {
            request = try JSONParameterEncoder().encode(request, with: requestParams)
        }

        RequestHashManager.shared.tryToAddHashHeader(for: self, in: &request)

        return request
    }

    private var requestParams: Parameters {
        switch self {
        case let .createProfile(_, params),
             let .updateProfile(_, params),
             let .syncInstallation(_, _, params),
             let .validateReceipt(params),
             let .trackEvent(params),
             let .signSubscriptionOffer(params),
             let .getPaywall(_, params),
             let .getProducts(params),
             let .updateAttribution(_, params),
             let .enableAnalytics(_, params),
             let .setTransactionVariationId(params):
            return params
        case .getPurchaserInfo:
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
            headers[API.Headers.authorization] = authorizationHeader
            headers[API.Headers.profileId] = DefaultsManager.shared.profileId
            headers[API.Headers.platform] = UserProperties.platform
            headers[API.Headers.version] = Adapty.SDKVersion
            headers[API.Headers.build] = String(Adapty.SDKBuild)
            headers[API.Headers.locale] = String(UserProperties.locale)
        }
        return headers
    }
}

extension Router {
    func logRequestStart() {
        let message = """
        Starting new request: \(method.rawValue.uppercased()) \(requestURL)
        Params: \(requestParams)
        Headers: \(requestHeaders.compactMapValues({ $0 }))
        """
        logMessage(message)
    }

    func logRequestRetry() {
        let message = """
        Retry request: \(method.rawValue.uppercased()) \(requestURL)
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

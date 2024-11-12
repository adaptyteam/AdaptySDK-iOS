//
//  Request.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty
import Foundation

enum Request {
    enum Method: String {
        case getSDKVersion = "get_sdk_version"
        case isActivated = "is_activated"
        case getLogLevel = "get_log_level"
        case setLogLevel = "set_log_level"
        case activate
        case getPaywall = "get_paywall"
        case getPaywallProducts = "get_paywall_products"
        case getProfile = "get_profile"
        case identify
        case logout
        case logShowOnboarding = "log_show_onboarding"
        case logShowPaywall = "log_show_paywall"
        case makePurchase = "make_purchase"
        case presentCodeRedemptionSheet = "present_code_redemption_sheet"
        case restorePurchases = "restore_purchases"
        case setFallbackPaywalls = "set_fallback_paywalls"
        case setVariationId = "set_variation_id"
        case updateAttribution = "update_attribution"
        case updateProfile = "update_profile"
    }

    static let allRequests: [Request.Method: AdaptyPluginRequest.Type] = [
        GetSDKVersion.method: GetSDKVersion.self,
        IsActivated.method: IsActivated.self,
        GetLogLevel.method: GetLogLevel.self,
        SetLogLevel.method: SetLogLevel.self,
        Activate.method: Activate.self,
        GetPaywall.method: GetPaywall.self,
        GetPaywallProducts.method: GetPaywallProducts.self,
        GetProfile.method: GetProfile.self,
        Identify.method: Identify.self,
        Logout.method: Logout.self,
        LogShowOnboarding.method: LogShowOnboarding.self,
        LogShowPaywall.method: LogShowPaywall.self,
        MakePurchase.method: MakePurchase.self,
        PresentCodeRedemptionSheet.method: PresentCodeRedemptionSheet.self,
        RestorePurchases.method: RestorePurchases.self,
        SetFallbackPaywalls.method: SetFallbackPaywalls.self,
        SetVariationId.method: SetVariationId.self,
        UpdateAttribution.method: UpdateAttribution.self,
        UpdateProfile.method: UpdateProfile.self
    ]
}

enum Response {}

extension Request {
    static func requestType(for method: String) throws -> AdaptyPluginRequest.Type {
        guard let method = Method(rawValue: method) else {
            throw RequestError.uncnownMethod(method)
        }
        return try requestType(for: method)
    }

    private static func requestType(for method: Method) throws -> AdaptyPluginRequest.Type {
        guard let requestType = allRequests[method] else {
            throw RequestError.notFoundRequest(method)
        }
        return requestType
    }
}

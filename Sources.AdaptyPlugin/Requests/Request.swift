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

        case adaptyUIActivate = "adapty_ui_activate"
        case adaptyUICreateView = "adapty_ui_create_view"
        case adaptyUIDismissView = "adpty_ui_dismiss_view"
        case adaptyUIPresentView = "adpty_ui_present_view"
        case adaptyUIShowDialog = "adpty_ui_show_dialog"
    }

    static let allRequests: [Request.Method: AdaptyPluginRequest.Type] = {
        var allRequests: [AdaptyPluginRequest.Type] = [
            GetSDKVersion.self,
            IsActivated.self,
            GetLogLevel.self,
            SetLogLevel.self,
            Activate.self,
            GetPaywall.self,
            GetPaywallProducts.self,
            GetProfile.self,
            Identify.self,
            Logout.self,
            LogShowOnboarding.self,
            LogShowPaywall.self,
            MakePurchase.self,
            PresentCodeRedemptionSheet.self,
            RestorePurchases.self,
            SetFallbackPaywalls.self,
            SetVariationId.self,
            UpdateAttribution.self,
            UpdateProfile.self
        ]

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            let adaptyUiRequests: [AdaptyPluginRequest.Type] = [
                AdaptyUIActivate.self,
                AdaptyUICreateView.self,
                AdaptyUIDismissView.self,
                AdaptyUIPresentView.self,
                AdaptyUIShowDialog.self
            ]
            allRequests.append(contentsOf: adaptyUiRequests)
        }

        return Dictionary(allRequests.map { ($0.method, $0) }) { _, last in last }
    }()
}

enum Response {}
extension Request {
    static func requestType(for method: String) throws -> AdaptyPluginRequest.Type {
        guard let method = Method(rawValue: method) else {
            throw AdaptyPluginDecodingError.uncnownMethod(method)
        }
        return try requestType(for: method)
    }

    private static func requestType(for method: Method) throws -> AdaptyPluginRequest.Type {
        guard let requestType = allRequests[method] else {
            throw AdaptyPluginDecodingError.notFoundRequest(method)
        }
        return requestType
    }
}

//
//  File.swift
//
//
//  Created by Aleksei Valiano on 30.04.2024
//
//

import Foundation

enum AdaptyCrossPlatform {}

extension AdaptyCrossPlatform {
    enum ArgumentName {
        static let value = "value"
        static let id = "id"
        static let placementId = "placement_id"
        static let fetchPolicy = "fetch_policy"
        static let loadTimeout = "load_timeout"
        static let paywall = "paywall"
        static let productsIds = "products_ids"
        static let locale = "locale"
        static let paywalls = "paywalls"
        static let customerUserId = "customer_user_id"
        static let params = "params"
        static let product = "product"
        static let attribution = "attribution"
        static let source = "source"
        static let networkUserId = "network_user_id"
        static let onboardingParams = "onboarding_params"
        static let transactionVariationId = "transaction_variation_id_data"
    }
}

extension AdaptyCrossPlatform {
    enum MethodName: String {
        case identify
        case logout

        case getProfile = "get_profile"
        case getPaywall = "get_paywall"
        case getPaywallProducts = "get_paywall_products"
        case getProductsIntroductoryOfferEligibility = "get_products_introductory_offer_eligibility"

        case makePurchase = "make_purchase"
        case restorePurchases = "restore_purchases"
        case updateAttribution = "update_attribution"

        case didUpdateProfile = "did_update_profile"
        case notImplemented = "not_implemented"

        case setLogLevel = "set_log_level"
        case updateProfile = "update_profile"
        case setFallbackPaywalls = "set_fallback_paywalls"
        case handlePushNotification = "handle_push_notification"
        case logShowPaywall = "log_show_paywall"
        case logShowOnboarding = "log_show_onboarding"
        case setTransactionVariationId = "set_transaction_variation_id"
        case presentCodeRedemptionSheet = "present_code_redemption_sheet"
    }
}

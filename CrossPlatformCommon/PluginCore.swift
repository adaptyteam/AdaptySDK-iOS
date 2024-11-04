//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 31.10.2024.
//

import Adapty
import AdaptyUI
import Foundation

public enum AdaptyCrossPlatformError: Error {
    case missingParameter(String)

    case notImplemented
}

public extension AdaptyCrossPlatform {
    static func handle(
        methodName: String,
        arguments: [String: Any]?
    ) async throws -> String? {
        switch MethodName(rawValue: methodName) ?? .notImplemented {
        case .activate:
            try await handleActivate(arguments)
            return nil
        case .setLogLevel:
            try handleSetLogLevel(arguments)
            return nil
        case .setFallbackPaywalls:
            try await handleSetFallbackPaywalls(arguments)
            return nil
//        case .identify: handleIdentify(call, result, args)
//        case .getPaywall: handleGetPaywall(call, result, args)
//        case .getPaywallProducts: handleGetPaywallProducts(call, result, args)
//        case .getProductsIntroductoryOfferEligibility: handleGetProductsIntroductoryOfferEligibility(call, result, args)
//        case .logShowPaywall: handleLogShowPaywall(call, result, args)
//        case .logShowOnboarding: handleLogShowOnboarding(call, result, args)
//        case .makePurchase: handleMakePurchase(call, result, args)
//        case .restorePurchases: handleRestorePurchases(call, result, args)
//        case .getProfile: handleGetProfile(call, result, args)
//        case .updateAttribution: handleUpdateAttribution(call, result, args)
//        case .logout: handleLogout(call, result, args)
//        case .updateProfile: handleUpdateProfile(call, result, args)
//        case .setTransactionVariationId: handleSetTransactionVariationId(call, result, args)
//        case .presentCodeRedemptionSheet: handlePresentCodeRedemptionSheet(call, result, args)
        default:
            throw AdaptyCrossPlatformError.notImplemented
        }
    }

    
    private static func handleActivate(
        _ args: [String: Any]?
    ) async throws {
        throw AdaptyCrossPlatformError.notImplemented
    }
    
    private static func handleSetLogLevel(
        _ args: [String: Any]?
    ) throws {
        guard let intValue = args?[ArgumentName.value] as? Int,
              let logLevel = AdaptyLog.Level(rawValue: intValue)
        else {
            throw AdaptyCrossPlatformError.missingParameter(ArgumentName.value)
        }

        Adapty.logLevel = logLevel
    }
    
    // MARK: - Set Fallback Paywalls

    private static func handleSetFallbackPaywalls(
        _ args: [String: Any]?
    ) async throws {
        guard let paywallsString = args?[ArgumentName.paywalls] as? String,
              let paywallsData = paywallsString.data(using: .utf8) else {
            throw AdaptyCrossPlatformError.missingParameter(ArgumentName.paywalls)
        }

        try await Adapty.setFallbackPaywalls(data: paywallsData)
    }

    // MARK: - Paywalls & Products

//    private func handleGetPaywall(_ flutterCall: FlutterMethodCall,
//                                  _ flutterResult: @escaping FlutterResult,
//                                  _ args: [String: Any]) {
//        guard let placementId = args[SwiftAdaptyFlutterConstants.placementId] as? String else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.placementId)
//            return
//        }
//
//        let locale = args[SwiftAdaptyFlutterConstants.locale] as? String
//        let fetchPolicy = (args[SwiftAdaptyFlutterConstants.fetchPolicy] as? String)
//            .flatMap { $0.data(using: .utf8) }
//            .flatMap { try? Self.jsonDecoder.decode(AdaptyPaywall.FetchPolicy.self, from: $0) }
//        let loadTimeout = args[SwiftAdaptyFlutterConstants.loadTimeout] as? TimeInterval
//
//        Adapty.getPaywall(placementId: placementId, locale: locale, fetchPolicy: fetchPolicy ?? .default, loadTimeout: loadTimeout ?? .defaultLoadPaywallTimeout) { result in
//            switch result {
//            case let .success(paywall):
//                flutterCall.callResult(resultModel: paywall, result: flutterResult)
//            case let .failure(error):
//                flutterCall.callAdaptyError(flutterResult, error: error)
//            }
//        }
//    }

//    private func handleGetPaywallProducts(_ flutterCall: FlutterMethodCall,
//                                          _ flutterResult: @escaping FlutterResult,
//                                          _ args: [String: Any]) {
//        guard let paywallString = args[SwiftAdaptyFlutterConstants.paywall] as? String,
//              let paywallData = paywallString.data(using: .utf8),
//              let paywall = try? Self.jsonDecoder.decode(AdaptyPaywall.self, from: paywallData) else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.paywall)
//            return
//        }
//
//        Adapty.getPaywallProducts(paywall: paywall) { result in
//            switch result {
//            case let .success(products):
//                flutterCall.callResult(resultModel: products, result: flutterResult)
//            case let .failure(error):
//                flutterCall.callAdaptyError(flutterResult, error: error)
//            }
//        }
//    }

//    private func handleGetProductsIntroductoryOfferEligibility(_ flutterCall: FlutterMethodCall,
//                                                               _ flutterResult: @escaping FlutterResult,
//                                                               _ args: [String: Any]) {
//        guard let productIds = args[SwiftAdaptyFlutterConstants.productsIds] as? [String] else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.productsIds)
//            return
//        }
//
//        Adapty.getProductsIntroductoryOfferEligibility(vendorProductIds: productIds) { result in
//            switch result {
//            case let .success(eligibilities):
//                flutterCall.callResult(resultModel: eligibilities, result: flutterResult)
//            case let .failure(error):
//                flutterCall.callAdaptyError(flutterResult, error: error)
//            }
//        }
//    }

    // MARK: - Identify & Profile

//    private func handleIdentify(_ flutterCall: FlutterMethodCall,
//                                _ flutterResult: @escaping FlutterResult,
//                                _ args: [String: Any]) {
//        guard let customerUserId = args[SwiftAdaptyFlutterConstants.customerUserId] as? String else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.customerUserId)
//            return
//        }
//
//        Adapty.identify(customerUserId) { error in
//            flutterCall.callAdaptyError(flutterResult, error: error)
//        }
//    }

//    private func handleGetProfile(_ flutterCall: FlutterMethodCall,
//                                  _ flutterResult: @escaping FlutterResult,
//                                  _ args: [String: Any]) {
//        Adapty.getProfile { result in
//            switch result {
//            case let .success(profile):
//                flutterCall.callResult(resultModel: profile, result: flutterResult)
//            case let .failure(error):
//                flutterCall.callAdaptyError(flutterResult, error: error)
//            }
//        }
//    }

//    private func handleUpdateProfile(_ flutterCall: FlutterMethodCall,
//                                     _ flutterResult: @escaping FlutterResult,
//                                     _ args: [String: Any]) {
//        guard let paramsString = args[SwiftAdaptyFlutterConstants.params] as? String,
//              let paramsData = paramsString.data(using: .utf8),
//              let params = try? Self.jsonDecoder.decode(AdaptyProfileParameters.self, from: paramsData) else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.paywall)
//            return
//        }
//
//        Adapty.updateProfile(params: params) { error in
//            if let error = error {
//                flutterCall.callAdaptyError(flutterResult, error: error)
//            } else {
//                flutterResult(nil)
//            }
//        }
//    }

    // MARK: - Make Purchase

//    private func handleMakePurchase(_ flutterCall: FlutterMethodCall,
//                                    _ flutterResult: @escaping FlutterResult,
//                                    _ args: [String: Any]) {
//        guard let productString = args[SwiftAdaptyFlutterConstants.product] as? String,
//              let productData = productString.data(using: .utf8) else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.product)
//            return
//        }
//
//        Adapty.getPaywallProduct(from: Self.jsonDecoder, data: productData) { result in
//            switch result {
//            case let .success(product):
//                Adapty.makePurchase(product: product) { result in
//                    switch result {
//                    case let .success(purchasedInfo):
//                        flutterCall.callResult(resultModel: purchasedInfo.profile,
//                                               result: flutterResult)
//                    case let .failure(error):
//                        flutterCall.callAdaptyError(flutterResult, error: error)
//                    }
//                }
//            case let .failure(error):
//                flutterCall.callAdaptyError(flutterResult, error: error)
//            }
//        }
//    }

    // MARK: - Restore Purchases

//    private func handleRestorePurchases(_ flutterCall: FlutterMethodCall,
//                                        _ flutterResult: @escaping FlutterResult,
//                                        _ args: [String: Any]) {
//        Adapty.restorePurchases { result in
//            switch result {
//            case let .success(profile):
//                flutterCall.callResult(resultModel: profile, result: flutterResult)
//            case let .failure(error):
//                flutterCall.callAdaptyError(flutterResult, error: error)
//            }
//        }
//    }

    // MARK: - Update Attribution

//    private func handleUpdateAttribution(_ flutterCall: FlutterMethodCall,
//                                         _ flutterResult: @escaping FlutterResult,
//                                         _ args: [String: Any]) {
//        guard let attribution = args[SwiftAdaptyFlutterConstants.attribution] as? [AnyHashable: Any] else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.attribution)
//            return
//        }
//        guard let sourceString = args[SwiftAdaptyFlutterConstants.source] as? String,
//              let source = AdaptyAttributionSource(rawValue: sourceString) else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.source)
//            return
//        }
//
//        let networkUserId = args[SwiftAdaptyFlutterConstants.networkUserId] as? String
//
//        Adapty.updateAttribution(attribution, source: source, networkUserId: networkUserId) { error in
//            if let error = error {
//                flutterCall.callAdaptyError(flutterResult, error: error)
//            } else {
//                flutterResult(nil)
//            }
//        }
//    }



//    private func handleLogShowPaywall(_ flutterCall: FlutterMethodCall,
//                                      _ flutterResult: @escaping FlutterResult,
//                                      _ args: [String: Any]) {
//        guard let paywallString = args[SwiftAdaptyFlutterConstants.paywall] as? String,
//              let paywallData = paywallString.data(using: .utf8),
//              let paywall = try? Self.jsonDecoder.decode(AdaptyPaywall.self, from: paywallData) else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.paywall)
//            return
//        }
//
//        Adapty.logShowPaywall(paywall) { error in
//            flutterCall.callAdaptyError(flutterResult, error: error)
//        }
//    }

//    private func handleLogShowOnboarding(_ flutterCall: FlutterMethodCall,
//                                         _ flutterResult: @escaping FlutterResult,
//                                         _ args: [String: Any]) {
//        guard let onboardingString = args[SwiftAdaptyFlutterConstants.onboardingParams] as? String,
//              let onboardingData = onboardingString.data(using: .utf8),
//              let onboardingParams = try? Self.jsonDecoder.decode(AdaptyOnboardingScreenParameters.self, from: onboardingData) else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.onboardingParams)
//            return
//        }
//
//        Adapty.logShowOnboarding(onboardingParams) { error in
//            flutterCall.callAdaptyError(flutterResult, error: error)
//        }
//    }

//    private func handleSetTransactionVariationId(_ flutterCall: FlutterMethodCall,
//                                                 _ flutterResult: @escaping FlutterResult,
//                                                 _ args: [String: Any]) {
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: args) else {
//            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyFlutterConstants.transactionVariationId)
//            return
//        }
//
//        Adapty.setVariationId(from: Self.jsonDecoder, data: jsonData) { error in
//            flutterCall.callAdaptyError(flutterResult, error: error)
//        }
//    }

//    private func handlePresentCodeRedemptionSheet(_ flutterCall: FlutterMethodCall,
//                                                  _ flutterResult: @escaping FlutterResult,
//                                                  _ args: [String: Any]) {
//        Adapty.presentCodeRedemptionSheet()
//        flutterResult(nil)
//    }

    // MARK: - Logout

//    private func handleLogout(_ flutterCall: FlutterMethodCall,
//                              _ flutterResult: @escaping FlutterResult,
//                              _ args: [String: Any]) {
//        Adapty.logout { error in
//            flutterCall.callAdaptyError(flutterResult, error: error)
//        }
//    }
}

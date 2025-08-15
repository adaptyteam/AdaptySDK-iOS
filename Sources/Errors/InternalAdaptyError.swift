//
//  InternalAdaptyError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.10.2022.
//

import Foundation
import StoreKit

enum InternalAdaptyError: Error {
    case unknown(AdaptyError.Source, String, error: Error)
    case activateOnceError(AdaptyError.Source)
    case cantMakePayments(AdaptyError.Source)
    case notActivated(AdaptyError.Source)
    case unidentifiedUserLogout(AdaptyError.Source)

    case profileWasChanged(AdaptyError.Source)
    case fetchFailed(AdaptyError.Source, String, error: Error)
    case decodingFailed(AdaptyError.Source, String, error: Error)

    case wrongParam(AdaptyError.Source, String)
}

extension InternalAdaptyError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .unknown(source, description, error: error):
            "AdaptyError.unknown(\(source), \(description), \(error))"
        case let .activateOnceError(source):
            "AdaptyError.activateOnceError(\(source))"
        case let .unidentifiedUserLogout(source):
            "AdaptyError.unidentifiedUserLogout(\(source))"
        case let .cantMakePayments(source):
            "AdaptyError.cantMakePayments(\(source))"
        case let .notActivated(source):
            "AdaptyError.notActivated(\(source))"
        case let .profileWasChanged(source):
            "AdaptyError.profileWasChanged(\(source))"
        case let .fetchFailed(source, description, error):
            "AdaptyError.fetchFailed(\(source), \(description), \(error))"
        case let .decodingFailed(source, description, error):
            "AdaptyError.decodingFailed(\(source), \(description), \(error))"
        case let .wrongParam(source, description):
            "AdaptyError.wrongParam(\(source), \(description))"
        }
    }
}

extension InternalAdaptyError {
    var source: AdaptyError.Source {
        switch self {
        case let .unknown(src, _, _),
             let .activateOnceError(src),
             let .unidentifiedUserLogout(src),
             let .cantMakePayments(src),
             let .notActivated(src),
             let .profileWasChanged(src),
             let .fetchFailed(src, _, _),
             let .decodingFailed(src, _, _),
             let .wrongParam(src, _):
            src
        }
    }

    var originalError: Error? {
        switch self {
        case let .unknown(_, _, error),
             let .decodingFailed(_, _, error),
             let .fetchFailed(_, _, error):
            error
        default:
            nil
        }
    }
}

extension InternalAdaptyError: CustomNSError {
    static let errorDomain = AdaptyError.AdaptyErrorDomain

    var adaptyErrorCode: AdaptyError.ErrorCode {
        switch self {
        case .unknown: .unknown
        case .activateOnceError: .activateOnceError
        case .unidentifiedUserLogout: .unidentifiedUserLogout
        case .cantMakePayments: .cantMakePayments
        case .notActivated: .notActivated
        case .profileWasChanged: .profileWasChanged
        case .fetchFailed: .networkFailed
        case .decodingFailed: .decodingFailed
        case .wrongParam: .wrongParam
        }
    }

    var errorCode: Int { adaptyErrorCode.rawValue }

    var errorUserInfo: [String: Any] {
        var data: [String: Any] = [
            AdaptyError.UserInfoKey.description: debugDescription,
            AdaptyError.UserInfoKey.source: source.description,
        ]

        if let originalError {
            data[NSUnderlyingErrorKey] = originalError as NSError
        }
        return data
    }
}

extension AdaptyError {
    static func activateOnceError(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalAdaptyError.activateOnceError(AdaptyError.Source(file: file, function: function, line: line)).asAdaptyError
    }

    static func unidentifiedUserLogout(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.unidentifiedUserLogout(AdaptyError.Source(file: file, function: function, line: line)).asAdaptyError
    }

    static func cantMakePayments(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalAdaptyError.cantMakePayments(AdaptyError.Source(file: file, function: function, line: line)).asAdaptyError
    }

    static func notActivated(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalAdaptyError.notActivated(AdaptyError.Source(file: file, function: function, line: line)).asAdaptyError
    }

    static func profileWasChanged(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalAdaptyError.profileWasChanged(AdaptyError.Source(file: file, function: function, line: line)).asAdaptyError
    }

    static func decodingFallback(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.decodingFailed(AdaptyError.Source(file: file, function: function, line: line), "Decoding Fallback Paywalls failed", error: error).asAdaptyError
    }

    static func isNotFileUrl(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(
            AdaptyError.Source(file: file, function: function, line: line), "Is not file URL"
        ).asAdaptyError
    }

    static func wrongVersionFallback(
        _ text: String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), text).asAdaptyError
    }

    static func decodingViewConfiguration(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.decodingFailed(AdaptyError.Source(file: file, function: function, line: line), "Decoding ViewConfiguration failed", error: error).asAdaptyError
    }

    static func wrongParamPurchasedTransaction(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), "Transaction is not in \"purchased\" state").asAdaptyError
    }

    static func wrongParamOnboardingScreenOrder(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), "Wrong screenOrder parameter value, it should be more than zero.").asAdaptyError
    }

    static func wrongKeyOfCustomAttribute(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), "The key must be string not more than 30 characters. Only letters, numbers, dashes, points and underscores allowed").asAdaptyError
    }

    static func wrongStringValueOfCustomAttribute(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), "The value must not be empty and not more than 50 characters.").asAdaptyError
    }

    static func wrongCountCustomAttributes(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), "The total number of custom attributes must be no more than 30").asAdaptyError
    }

    static func wrongAttributeData(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), error.localizedDescription).asAdaptyError
    }

    static func isNoViewConfigurationInPaywall(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), "AdaptyPaywall.viewConfiguration is nil").asAdaptyError
    }

    static func paywallWithoutPurchaseUrl(
        paywall: AdaptyPaywall,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), "Current method is not available for the paywall (placementId: \(paywall.placement.id), name: \(paywall.name), variationId: \(paywall.variationId))").asAdaptyError
    }

    static func productWithoutPurchaseUrl(
        adaptyProductId: String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), "Current method is not available for the product:\(adaptyProductId)").asAdaptyError
    }

    static func failedDecodingWebPaywallUrl(
        url: URL,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.decodingFailed(AdaptyError.Source(file: file, function: function, line: line), "Failed decoding web paywall url:\(url)", error: URLError(.badURL)).asAdaptyError
    }

    static func failedOpeningWebPaywallUrl(
        _ url: URL,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.wrongParam(AdaptyError.Source(file: file, function: function, line: line), "Failed opening web paywall url: \(url)").asAdaptyError
    }

    static func unknown(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.unknown(AdaptyError.Source(file: file, function: function, line: line), "Unexpected error", error: error).asAdaptyError
    }
}

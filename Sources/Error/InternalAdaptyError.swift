//
//  InternalAdaptyError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.10.2022.
//

import Foundation
import StoreKit

enum InternalAdaptyError: Error {
    case activateOnceError(AdaptyError.Source)
    case cantMakePayments(AdaptyError.Source)
    case notActivated(AdaptyError.Source)
    case profileWasChanged(AdaptyError.Source)
    case profileCreateFailed(AdaptyError.Source, error: HTTPError)
    case decodingFailed(AdaptyError.Source, String, error: Error)
    case wrongParam(AdaptyError.Source, String)
    case fetchTimeoutError(AdaptyError.Source, String)
}

extension InternalAdaptyError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .activateOnceError(source):
            "AdaptyError.activateOnceError(\(source))"
        case let .cantMakePayments(source):
            "AdaptyError.cantMakePayments(\(source))"
        case let .notActivated(source):
            "AdaptyError.notActivated(\(source))"
        case let .profileWasChanged(source):
            "AdaptyError.profileWasChanged(\(source))"
        case let .profileCreateFailed(source, error):
            "AdaptyError.profileCreateFailed(\(source), \(error))"
        case let .decodingFailed(source, description, error):
            "AdaptyError.decodingFailed(\(source), \(description), \(error))"
        case let .wrongParam(source, description):
            "AdaptyError.wrongParam(\(source), \(description))"
        case let .fetchTimeoutError(source, description):
            "AdaptyError.fetchTimeoutError(\(source), \(description))"
        }
    }
}

extension InternalAdaptyError {
    var source: AdaptyError.Source {
        switch self {
        case let .activateOnceError(src),
             let .cantMakePayments(src),
             let .notActivated(src),
             let .profileWasChanged(src),
             let .profileCreateFailed(src, _),
             let .decodingFailed(src, _, _),
             let .wrongParam(src, _),
             let .fetchTimeoutError(src, _):
            src
        }
    }

    var originalError: Error? {
        switch self {
        case let .profileCreateFailed(_, error):
            error
        case let .decodingFailed(_, _, error):
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
        case .activateOnceError: AdaptyError.ErrorCode.activateOnceError
        case .cantMakePayments: AdaptyError.ErrorCode.cantMakePayments
        case .notActivated: AdaptyError.ErrorCode.notActivated
        case .profileWasChanged: AdaptyError.ErrorCode.profileWasChanged
        case let .profileCreateFailed(_, error): error.adaptyErrorCode
        case .decodingFailed: AdaptyError.ErrorCode.decodingFailed
        case .wrongParam: AdaptyError.ErrorCode.wrongParam
        case .fetchTimeoutError: AdaptyError.ErrorCode.fetchTimeoutError
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

    static func cantMakePayments(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalAdaptyError.cantMakePayments(AdaptyError.Source(file: file, function: function, line: line)).asAdaptyError
    }

    static func notActivated(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalAdaptyError.notActivated(AdaptyError.Source(file: file, function: function, line: line)).asAdaptyError
    }

    static func profileWasChanged(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalAdaptyError.profileWasChanged(AdaptyError.Source(file: file, function: function, line: line)).asAdaptyError
    }

    static func profileCreateFailed(_ error: HTTPError, file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalAdaptyError.profileCreateFailed(AdaptyError.Source(file: file, function: function, line: line), error: error).asAdaptyError
    }

    var isProfileCreateFailed: Bool {
        guard let error = wrapped as? InternalAdaptyError else { return false }
        switch error {
        case .profileCreateFailed:
            return true
        default:
            return false
        }
    }

    static func decodingFallback(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.decodingFailed(AdaptyError.Source(file: file, function: function, line: line), "Decoding Fallback Paywalls failed", error: error).asAdaptyError
    }

    static func decodingSetVariationIdParams(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.decodingFailed(AdaptyError.Source(file: file, function: function, line: line), "Decoding SetVariationIdParams failed", error: error).asAdaptyError
    }

    static func decodingGetViewConfiguration(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.decodingFailed(AdaptyError.Source(file: file, function: function, line: line), "Decoding GetViewConfigurationParams failed", error: error).asAdaptyError
    }

    static func decodingPaywallProduct(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.decodingFailed(AdaptyError.Source(file: file, function: function, line: line), "Decoding AdaptyPaywallProduct failed", error: error).asAdaptyError
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

    static func fetchPaywallTimeout(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.fetchTimeoutError(AdaptyError.Source(file: file, function: function, line: line), "Request Paywall timeout").asAdaptyError
    }

    static func fetchViewConfigurationTimeout(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalAdaptyError.fetchTimeoutError(AdaptyError.Source(file: file, function: function, line: line), "Request ViewConfiguration timeout").asAdaptyError
    }

    var canUseFallbackServer: Bool {
        if let error = wrapped as? InternalAdaptyError {
            if case .fetchTimeoutError = error { return true }
        } else if let error = wrapped as? HTTPError {
            return Backend.canUseFallbackServer(error)
        }
        return false
    }
}

//
//  CustomAdaptyError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 27.01.2023
//

import StoreKit

package protocol CustomAdaptyError: CustomStringConvertible, CustomDebugStringConvertible, CustomNSError {
    var originalError: Error? { get }
    var adaptyErrorCode: AdaptyError.ErrorCode { get }
}

extension CustomAdaptyError {
    var asAdaptyError: AdaptyError {
        AdaptyError(self)
    }
}

extension Error {
    var asAdaptyError: AdaptyError? {
        if let error = self as? AdaptyError { return error }
        if let error = self as? CustomAdaptyError { return AdaptyError(error) }
        return nil
    }

    var unwrapped: Error {
        if let adaptyError = self as? AdaptyError {
            adaptyError.wrapped
        } else {
            self
        }
    }
}

extension InternalAdaptyError: CustomAdaptyError {}

extension HTTPError: CustomAdaptyError {
    static let errorDomain = AdaptyError.HTTPErrorDomain

    var errorCode: Int { adaptyErrorCode.rawValue }

    var errorUserInfo: [String: Any] {
        var data: [String: Any] = [
            AdaptyError.UserInfoKey.description: debugDescription,
            AdaptyError.UserInfoKey.source: source.description,
            AdaptyError.UserInfoKey.endpoint: endpoint.description,
        ]
        if let statusCode {
            data[AdaptyError.UserInfoKey.statusCode] = NSNumber(value: statusCode)
        }
        if let originalError {
            data[NSUnderlyingErrorKey] = originalError as NSError
        }
        return data
    }

    var adaptyErrorCode: AdaptyError.ErrorCode {
        if isCancelled { return .operationInterrupted }
        switch self {
        case .perform: return .encodingFailed
        case .network: return .networkFailed
        case .decoding: return .decodingFailed
        case let .backend(_, _, statusCode, _, _, _):
            return Backend.toAdaptyErrorCode(statusCode: statusCode) ?? .networkFailed
        }
    }
}

extension EventsError: CustomAdaptyError {
    static let errorDomain = AdaptyError.EventsErrorDomain

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

    var adaptyErrorCode: AdaptyError.ErrorCode {
        switch self {
        case .sending: .networkFailed
        case .encoding: .encodingFailed
        case .decoding: .decodingFailed
        }
    }
}

extension StoreKitManagerError: CustomAdaptyError {
    static let errorDomain = AdaptyError.SKManagerErrorDomain

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

    var adaptyErrorCode: AdaptyError.ErrorCode {
        if let code = convertErrorCode(skError) { return code }
        switch self {
        case .interrupted: return .operationInterrupted
        case .noProductIDsFound: return .noProductIDsFound
        case .receiptIsEmpty: return .cantReadReceipt
        case .refreshReceiptFailed: return .refreshReceiptFailed
        case .requestSKProductsFailed: return .productRequestFailed
        case .productPurchaseFailed: return .productPurchaseFailed
        case let .transactionUnverified(_, error):
            if let customError = error as? CustomAdaptyError {
                return customError.adaptyErrorCode
            } else {
                return .networkFailed
            }
        case .invalidOffer: return .invalidOfferIdentifier
        case .getSubscriptionInfoStatusFailed: return .fetchSubscriptionStatusFailed
        }
    }

    func convertErrorCode(_ error: SKError?) -> AdaptyError.ErrorCode? {
        guard let error else { return nil }
        return AdaptyError.ErrorCode(rawValue: error.code.rawValue)
    }
}

//
//  CustomAdaptyError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 27.01.2023
//

import StoreKit

public protocol CustomAdaptyError: CustomStringConvertible, CustomDebugStringConvertible, CustomNSError {
    var originalError: Error? { get }
    var adaptyErrorCode: AdaptyError.ErrorCode { get }
}

extension CustomAdaptyError {
    var asAdaptyError: AdaptyError {
        AdaptyError(self)
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
        case let .backend(_, _, code, _, _):
            return Backend.toAdaptyErrorCode(statusCode: code) ?? .networkFailed
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
        case .interrupted: .operationInterrupted
        }
    }
}

extension SKManagerError: CustomAdaptyError {
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
        }
    }

    func convertErrorCode(_ error: SKError?) -> AdaptyError.ErrorCode? {
        guard let error else { return nil }
        return AdaptyError.ErrorCode(rawValue: error.code.rawValue)
    }
}

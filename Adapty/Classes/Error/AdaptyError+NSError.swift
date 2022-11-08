//
//  AdaptyError+NSErrors.swift
//  Adapty
//
//  Created by Aleksei Valiano on 30.10.2022.
//

import StoreKit

extension HTTPError: CustomNSError {
    static let errorDomain = AdaptyError.HTTPErrorDomain

    var errorCode: Int {
        if isCancelled { return AdaptyError.HTTPErrorCode.cancelled }
        switch self {
        case .perform: return AdaptyError.HTTPErrorCode.perform
        case .network: return AdaptyError.HTTPErrorCode.network
        case .decoding: return AdaptyError.HTTPErrorCode.decoding
        case .backend: return AdaptyError.HTTPErrorCode.backend
        }
    }

    var errorUserInfo: [String: Any] {
        var data: [String: Any] = [
            AdaptyError.UserInfoKey.description: debugDescription,
            AdaptyError.UserInfoKey.source: source.description,
            AdaptyError.UserInfoKey.endpoint: endpoint.description,
        ]
        if let statusCode = statusCode {
            data[AdaptyError.UserInfoKey.statusCode] = NSNumber(value: statusCode)
        }
        if let originalError = originalError {
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
        case let .backend(_, _, code, _):
            return Backend.toAdaptyErrorCode(statusCode: code) ?? .networkFailed
        }
    }

    var asAdaptyError: AdaptyError {
        AdaptyError(wrapped: .originalHTTPError(self))
    }
}

extension EventsError: CustomNSError {
    static let errorDomain = AdaptyError.EventsErrorDomain

    var errorCode: Int {
        switch self {
        case .interrupted: return AdaptyError.EventsErrorCode.interrupted
        case .sending: return AdaptyError.EventsErrorCode.sending
        case .analyticsDisabled: return AdaptyError.EventsErrorCode.analyticsDisabled
        case .encoding: return AdaptyError.EventsErrorCode.encoding
        }
    }

    var errorUserInfo: [String: Any] {
        var data: [String: Any] = [
            AdaptyError.UserInfoKey.description: debugDescription,
            AdaptyError.UserInfoKey.source: source.description,
        ]
        if let originalError = originalError {
            data[NSUnderlyingErrorKey] = originalError as NSError
        }
        return data
    }

    var adaptyErrorCode: AdaptyError.ErrorCode {
        switch self {
        case .sending: return .networkFailed
        case .analyticsDisabled: return .analyticsDisabled
        case .encoding: return .encodingFailed
        case .interrupted: return .operationInterrupted
        }
    }

    var asAdaptyError: AdaptyError {
        AdaptyError(wrapped: .originalEventsError(self))
    }
}

extension SKManagerError: CustomNSError {
    static let errorDomain = AdaptyError.SKManagerErrorDomain

    var errorCode: Int {
        switch self {
        case .interrupted: return AdaptyError.SKManagerErrorCode.interrupted
        case .noProductIDsFound: return AdaptyError.SKManagerErrorCode.noProductIDsFound
        case .receiptIsEmpty: return AdaptyError.SKManagerErrorCode.receiptIsEmpty
        case .productPurchaseFailed: return AdaptyError.SKManagerErrorCode.productPurchaseFailed
        case .noPurchasesToRestore: return AdaptyError.SKManagerErrorCode.noPurchasesToRestore
        case .refreshReceiptFailed: return AdaptyError.SKManagerErrorCode.refreshReceiptFailed
        case .receiveRestoredTransactionsFailed: return AdaptyError.SKManagerErrorCode.receiveRestoredTransactionsFailed
        case .requestSKProductsFailed: return AdaptyError.SKManagerErrorCode.requestSKProductsFailed
        }
    }

    var errorUserInfo: [String: Any] {
        var data: [String: Any] = [
            AdaptyError.UserInfoKey.description: debugDescription,
            AdaptyError.UserInfoKey.source: source.description,
        ]
        if let originalError = originalError {
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
        case .receiveRestoredTransactionsFailed: return .receiveRestoredTransactionsFailed
        case .requestSKProductsFailed: return .productRequestFailed
        case .productPurchaseFailed: return .productPurchaseFailed
        case .noPurchasesToRestore: return .noPurchasesToRestore
        }
    }

    func convertErrorCode(_ error: SKError?) -> AdaptyError.ErrorCode? {
        guard let error = error else { return nil }
        return AdaptyError.ErrorCode(rawValue: error.code.rawValue)
    }

    var asAdaptyError: AdaptyError {
        AdaptyError(wrapped: .originalSKManagerError(self))
    }
}

extension KinesisError: CustomNSError {
    static let errorDomain = AdaptyError.KinesisErrorDomain

    var errorCode: Int {
        switch self {
        case .missingСredentials: return AdaptyError.KinesisErrorCode.missingСredentials
        case .requestWithoutURL: return AdaptyError.KinesisErrorCode.requestWithoutURL
        case .requestWithoutHTTPMethod: return AdaptyError.KinesisErrorCode.requestWithoutHTTPMethod
        case .urlWithoutHost: return AdaptyError.KinesisErrorCode.urlWithoutHost
        }
    }

    var errorUserInfo: [String: Any] { [
        AdaptyError.UserInfoKey.description: debugDescription,
        AdaptyError.UserInfoKey.source: source.description,
    ] }
}

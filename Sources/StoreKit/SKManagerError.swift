//
//  SKManagerError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

enum SKManagerError: Error {
    case interrupted(AdaptyError.Source)
    case noProductIDsFound(AdaptyError.Source)
    case receiptIsEmpty(AdaptyError.Source, error: Error?)
    case refreshReceiptFailed(AdaptyError.Source, error: Error)
    case requestSKProductsFailed(AdaptyError.Source, error: Error)
    case productPurchaseFailed(AdaptyError.Source, transactionError: Error?)
}

extension SKManagerError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .interrupted(source):
            "StoreKitManagerError.interrupted(\(source))"
        case let .noProductIDsFound(source):
            "StoreKitManagerError.noProductIDsFound(\(source))"
        case let .receiptIsEmpty(source, error):
            if let error {
                "StoreKitManagerError.receiptIsEmpty(\(source), \(error)"
            } else {
                "StoreKitManagerError.receiptIsEmpty(\(source))"
            }
        case let .refreshReceiptFailed(source, error):
            "StoreKitManagerError.refreshReceiptFailed(\(source), \(error)"
        case let .requestSKProductsFailed(source, error):
            "StoreKitManagerError.requestSK1ProductsFailed(\(source), \(error)"
        case let .productPurchaseFailed(source, error):
            if let error {
                "StoreKitManagerError.productPurchaseFailed(\(source), \(error))"
            } else {
                "StoreKitManagerError.productPurchaseFailed(\(source))"
            }
        }
    }
}

extension SKManagerError {
    var source: AdaptyError.Source {
        switch self {
        case let .productPurchaseFailed(src, _),
             let .noProductIDsFound(src),
             let .receiptIsEmpty(src, _),
             let .refreshReceiptFailed(src, _),
             let .requestSKProductsFailed(src, _),
             let .interrupted(src): src
        }
    }

    var originalError: Error? {
        switch self {
        case let .receiptIsEmpty(_, error),
             let .productPurchaseFailed(_, error): error
        case let .refreshReceiptFailed(_, error),
             let .requestSKProductsFailed(_, error): error
        default: nil
        }
    }

    var skError: SKError? {
        guard let originalError else { return nil }
        return originalError as? SKError
    }
}

extension SKManagerError {
    static func noProductIDsFound(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .noProductIDsFound(AdaptyError.Source(file: file, function: function, line: line))
    }

    static func productPurchaseFailed(_ error: Error?, file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        .productPurchaseFailed(AdaptyError.Source(file: file, function: function, line: line), transactionError: error)
    }

    static func receiptIsEmpty(_ error: Error? = nil, file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        .receiptIsEmpty(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func refreshReceiptFailed(_ error: Error, file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        .refreshReceiptFailed(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func requestSK1ProductsFailed(_ error: Error, file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        .requestSKProductsFailed(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func requestSK2ProductsFailed(_ error: Error, file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        .requestSKProductsFailed(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func requestSK2IsEligibleForIntroOfferFailed(_ error: Error, file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        .requestSKProductsFailed(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func interrupted(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        .interrupted(AdaptyError.Source(file: file, function: function, line: line))
    }
}

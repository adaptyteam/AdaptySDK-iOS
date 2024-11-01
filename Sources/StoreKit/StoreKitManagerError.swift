//
//  StoreKitManagerError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

enum StoreKitManagerError: Error {
    case interrupted(AdaptyError.Source)
    case noProductIDsFound(AdaptyError.Source)
    case receiptIsEmpty(AdaptyError.Source, error: Error?)
    case refreshReceiptFailed(AdaptyError.Source, error: Error)
    case requestSKProductsFailed(AdaptyError.Source, error: Error)
    case productPurchaseFailed(AdaptyError.Source, transactionError: Error?)
    case trunsactionUnverified(AdaptyError.Source, error: Error?)
    case unknownIntroEligibility(AdaptyError.Source)
    case purchasingNotDeterminedOffer(AdaptyError.Source)
    case purchasingWinBackOfferFailed(AdaptyError.Source, error: String)
    case getSubscriptionInfoStatusFailed(AdaptyError.Source, error: Error)
}

extension StoreKitManagerError: CustomStringConvertible {
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
        case let .trunsactionUnverified(source, error):
            if let error {
                "StoreKitManagerError.trunsactionUnverified(\(source), \(error))"
            } else {
                "StoreKitManagerError.trunsactionUnverified(\(source))"
            }
        case let .unknownIntroEligibility(source):
            "StoreKitManagerError.unknownIntroEligibility(\(source))"
        case let .purchasingNotDeterminedOffer(source):
            "StoreKitManagerError.purchasingNotDeterminedOffer(\(source))"
        case let .purchasingWinBackOfferFailed(source, error):
            "StoreKitManagerError.purchasingWinBackOfferFailed(\(source), \"\(error)\")"
        case let .getSubscriptionInfoStatusFailed(source, error):
            "StoreKitManagerError.getSubscriptionInfoStatusFailed(\(source), \(error))"
        }
    }
}

extension StoreKitManagerError {
    var source: AdaptyError.Source {
        switch self {
        case let .productPurchaseFailed(src, _),
             let .noProductIDsFound(src),
             let .receiptIsEmpty(src, _),
             let .refreshReceiptFailed(src, _),
             let .requestSKProductsFailed(src, _),
             let .interrupted(src),
             let .trunsactionUnverified(src, _),
             let .unknownIntroEligibility(src),
             let .purchasingNotDeterminedOffer(src),
             let .purchasingWinBackOfferFailed(src, _),
             let .getSubscriptionInfoStatusFailed(src, _): src
        }
    }

    var originalError: Error? {
        switch self {
        case let .receiptIsEmpty(_, error),
             let .productPurchaseFailed(_, error),
             let .trunsactionUnverified(_, error): error
        case let .refreshReceiptFailed(_, error),
             let .getSubscriptionInfoStatusFailed(_, error),
             let .requestSKProductsFailed(_, error): error
        default: nil
        }
    }

    var skError: SKError? {
        guard let originalError else { return nil }
        return originalError as? SKError
    }
}

extension StoreKitManagerError {
    static func noProductIDsFound(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .noProductIDsFound(AdaptyError.Source(file: file, function: function, line: line))
    }

    static func productPurchaseFailed(
        _ error: Error?,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .productPurchaseFailed(AdaptyError.Source(file: file, function: function, line: line), transactionError: error)
    }

    static func receiptIsEmpty(
        _ error: Error? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .receiptIsEmpty(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func refreshReceiptFailed(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .refreshReceiptFailed(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func requestSK1ProductsFailed(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .requestSKProductsFailed(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func requestSK2ProductsFailed(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .requestSKProductsFailed(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func requestSK2IsEligibleForIntroOfferFailed(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .requestSKProductsFailed(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func interrupted(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .interrupted(AdaptyError.Source(file: file, function: function, line: line))
    }

    static func trunsactionUnverified(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .trunsactionUnverified(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func purchasingNotDeterminedOffer(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .purchasingNotDeterminedOffer(AdaptyError.Source(file: file, function: function, line: line))
    }

    static func purchasingWinBackOfferFailed(
        _ error: String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .purchasingWinBackOfferFailed(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }

    static func unknownIntroEligibility(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .unknownIntroEligibility(AdaptyError.Source(file: file, function: function, line: line))
    }

    static func getSubscriptionInfoStatusFailed(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .getSubscriptionInfoStatusFailed(AdaptyError.Source(file: file, function: function, line: line), error: error)
    }
}

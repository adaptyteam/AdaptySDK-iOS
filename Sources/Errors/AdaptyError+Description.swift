//
//  AdaptyError+Description.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.10.2022.
//

import Foundation

extension InternalAdaptyError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .unknown(_, description, _): description
        case .activateOnceError: "Adapty can only be activated once. Please check your initialization code."
        case .cantMakePayments: "In-App Purchases are not available on this device. Please check your device settings."
        case .notActivated: "Adapty SDK is not initialized. Please call activate() before using other methods."
        case .profileWasChanged: "The user profile has been updated while performing the operation. Please try again."
        case .profileCreateFailed: "Failed to create a new user profile."
        case let .fetchFailed(_, description, _): description
        case let .decodingFailed(_, description, _): description
        case let .wrongParam(_, description): description
        }
    }
}

extension HTTPError: CustomDebugStringConvertible {
    var debugDescription: String {
        if isCancelled { return "The request was cancelled." }
        switch self {
        case .perform: return "Failed to execute the request. Please check your internet connection."
        case .network: return "Network connection error. Please check your internet connection and try again."
        case .decoding: return "Failed to process the server response. Please try again later or contact support if the issue persists."
        case .backend: return "Server error. Please try again later or contact support if the issue persists."
        }
    }
}

extension EventsError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .interrupted: "The operation was interrupted."
        case .sending: "Failed to send event data."
        case .decoding: "Failed to process event data."
        case .encoding: "Failed to prepare event data."
        }
    }
}

extension StoreKitManagerError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .interrupted: "The purchase operation was interrupted. Please try again."
        case .noProductIDsFound: "No valid In-App Purchase products were found. Please check your product configuration on the App Store Connect and Adapty Dashboard."
        case .receiptIsEmpty: "No valid purchase receipt found."
        case .refreshReceiptFailed: "Failed to refresh the purchase receipt."
        case .productPurchaseFailed: "The purchase could not be completed."
        case .requestSKProductsFailed: "Failed to fetch product information from the StoreKit. Please check your internet connection."
        case let .transactionUnverified(_, error):
            if let customError = error as? CustomAdaptyError {
                "Transaction verification failed: \(customError.debugDescription)"
            } else {
                "Transaction verification failed."
            }
        case let .invalidOffer(_, error):
            error
        case .getSubscriptionInfoStatusFailed: "Failed to retrieve subscription information."
        }
    }
}

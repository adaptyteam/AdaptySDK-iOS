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
        case .activateOnceError: "Adapty can only be activated once. Ensure that the SDK activation call is not made more than once."
        case .cantMakePayments: "In-App Purchases are not available on this device. Please check your device settings."
        case .notActivated: "Adapty SDK is not initialized. You need to activate the SDK before using its methods."
        case .profileWasChanged: "The user was replaced with a different user in the SDK during the execution of the operation."
        case let .fetchFailed(_, description, _): description
        case let .decodingFailed(_, description, _): description
        case let .wrongParam(_, description): description
        }
    }
}

extension HTTPError: CustomDebugStringConvertible {
    var debugDescription: String {
        if isCancelled { return "The network request was cancelled." }
        switch self {
        case .perform: return "Failed to prepare the network request. See the original error for more details."
        case .network: return "Network request error. See the original error for more details."
        case .decoding: return "Unable to decode the server response. Refer to the original error for additional context. Please try again later or contact support if the issue persists."
        case .backend: return "An error was returned by the server. See the original error for details. Contact support if the issue persists."
        }
    }
}

extension EventsError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .sending: "Failed to send event data to the server."
        case .decoding: "Failed to decode stored event data."
        case .encoding: "Failed to encode event data."
        }
    }
}

extension StoreKitManagerError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .interrupted: "The operation was interrupted."
        case .noProductIDsFound: "No valid In-App Purchase products were found. Please check your product configuration on the App Store Connect and Adapty Dashboard."
        case .receiptIsEmpty: "No valid purchase receipt found."
        case .refreshReceiptFailed: "Failed to refresh the purchase receipt."
        case .productPurchaseFailed: "Failed to complete the product purchase. Refer to the original error for more details."
        case .requestSKProductsFailed: "Failed to fetch product information from the StoreKit. Refer to the original error for more details."
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

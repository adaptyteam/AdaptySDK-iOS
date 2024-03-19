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
        case .activateOnceError: "You need to be activate Adapty once"
        case .cantMakePayments: "In-App Purchases are not allowed on this device"
        case .notActivated: "The Adapty is not activated"
        case .profileWasChanged: "The user profile was replaced"
        case .profileCreateFailed: "Unable to create user profile"
        case let .decodingFailed(_, description, _): description
        case let .wrongParam(_, description): description
        case let .fetchTimeoutError(_, description): description
        }
    }
}

extension HTTPError: CustomDebugStringConvertible {
    var debugDescription: String {
        if isCancelled { return "Request cancelled" }
        switch self {
        case .perform: return "Perform request failed"
        case .network: return "Network error"
        case .decoding: return "Response decoding failed"
        case .backend: return "Server error"
        }
    }
}

extension EventsError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .interrupted: "Operation interrupted"
        case .sending: "Network request failed"
        case .decoding: "Event decoding failed"
        case .encoding: "Event encoding failed"
        }
    }
}

extension SKManagerError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .interrupted: "Operation interrupted"
        case .noProductIDsFound: "No In-App Purchase product identifiers were found."
        case .receiptIsEmpty: "Can't find a valid receipt"
        case .refreshReceiptFailed: "Refresh receipt failed"
        case .productPurchaseFailed: "Product purchase failed"
        case .requestSKProductsFailed: "Request products form App Store failed"
        }
    }
}

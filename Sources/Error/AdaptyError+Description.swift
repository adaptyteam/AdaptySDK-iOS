//
//  AdaptyError+Description.swift
//  Adapty
//
//  Created by Aleksei Valiano on 30.10.2022.
//

import Foundation

extension InternalAdaptyError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .activateOnceError: return "You need to be activate Adapty once"
        case .cantMakePayments: return "In-App Purchases are not allowed on this device"
        case .notActivated: return "The Adapty is not activated"
        case .profileWasChanged: return "The user profile was replaced"
        case .profileCreateFailed: return "Unable to create user profile"
        case let .decodingFailed(_, description, _): return description
        case let .wrongParam(_, description): return description
        case let .persistingDataError(_, description): return description
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
        case .interrupted: return "Operation interrupted"
        case .sending: return "Network request failed"
        case .decoding: return "Event decoding failed"
        case .encoding: return "Event encoding failed"
        }
    }
}

extension SKManagerError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .interrupted: return "Operation interrupted"
        case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
        case .receiptIsEmpty: return "Can't find a valid receipt"
        case .refreshReceiptFailed: return "Refresh receipt failed"
        case .productPurchaseFailed: return "Product purchase failed"
        case .requestSKProductsFailed: return "Request products form App Store failed"
        }
    }
}

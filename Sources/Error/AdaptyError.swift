//
//  AdaptyError.swift
//  Adapty
//
//  Created by Aleksei Valiano on 30.10.2022.
//

import Foundation
import StoreKit

extension AdaptyError {
    public static let AdaptyErrorDomain = "AdaptyErrorDomain"
    public static let HTTPErrorDomain = "AdaptyHTTPErrorDomain"
    public static let EventsErrorDomain = "AdaptyEventsErrorDomain"
    public static let SKManagerErrorDomain = "AdaptySKManagerErrorDomain"
    public static let KinesisErrorDomain = "AdaptyKinesisErrorDomain"

    public enum HTTPErrorCode {
        public static let cancelled = ErrorCode.operationInterrupted.rawValue
        public static let perform = ErrorCode.encodingFailed.rawValue
        public static let network = ErrorCode.networkFailed.rawValue
        public static let decoding = ErrorCode.decodingFailed.rawValue
        public static let backend = ErrorCode.serverError.rawValue
    }

    public enum EventsErrorCode {
        public static let interrupted = ErrorCode.operationInterrupted.rawValue
        public static let sending = ErrorCode.networkFailed.rawValue
        public static let analyticsDisabled = ErrorCode.analyticsDisabled.rawValue
        public static let encoding = ErrorCode.encodingFailed.rawValue
    }

    public enum SKManagerErrorCode {
        public static let interrupted = ErrorCode.operationInterrupted.rawValue
        public static let noProductIDsFound = ErrorCode.noProductIDsFound.rawValue
        public static let receiptIsEmpty = ErrorCode.cantReadReceipt.rawValue
        public static let productPurchaseFailed = ErrorCode.productPurchaseFailed.rawValue
        public static let noPurchasesToRestore = ErrorCode.noPurchasesToRestore.rawValue
        public static let refreshReceiptFailed = ErrorCode.refreshReceiptFailed.rawValue
        public static let receiveRestoredTransactionsFailed = ErrorCode.receiveRestoredTransactionsFailed.rawValue
        public static let requestSKProductsFailed = ErrorCode.productRequestFailed.rawValue
    }

    public enum KinesisErrorCode {
        public static let missingСredentials = 5001
        public static let requestWithoutURL = 5002
        public static let requestWithoutHTTPMethod = 5003
        public static let urlWithoutHost = 5004
    }

    public enum UserInfoKey {
        public static let description = NSDebugDescriptionErrorKey
        public static let source = "AdaptySourceErrorKey"
        public static let endpoint = "AdaptyHTTPEndpointErrorKey"
        public static let statusCode = "AdaptyHTTPStatusCodeErrorKey"
    }

    public enum ErrorCode: Int {
        // system StoreKit codes
        case unknown = 0

        /// Client is not allowed to make a request, etc.
        case clientInvalid = 1

        /// User cancelled the request, etc.
        case paymentCancelled = 2

        /// Invalid purchase identifier, etc.
        case paymentInvalid = 3

        /// This device is not allowed to make the payment.
        case paymentNotAllowed = 4

        /// Product is not available in the current storefront.
        case storeProductNotAvailable = 5

        /// User has not allowed access to cloud service information.
        case cloudServicePermissionDenied = 6

        /// The device could not connect to the network.
        case cloudServiceNetworkConnectionFailed = 7

        /// User has revoked permission to use this cloud service.
        case cloudServiceRevoked = 8

        /// The user needs to acknowledge Apple's privacy policy.
        case privacyAcknowledgementRequired = 9

        /// The app is attempting to use SKPayment's requestData property, but does not have the appropriate entitlement.
        case unauthorizedRequestData = 10

        /// The specified subscription offer identifier is not valid.
        case invalidOfferIdentifier = 11

        /// The cryptographic signature provided is not valid.
        case invalidSignature = 12

        /// One or more parameters from SKPaymentDiscount is missing.
        case missingOfferParams = 13

        ///
        case invalidOfferPrice = 14

        case noProductIDsFound = 1000
        ///
        case productRequestFailed = 1002

        /// In-App Purchases are not allowed on this device.
        case cantMakePayments = 1003
        case noPurchasesToRestore = 1004
        case cantReadReceipt = 1005
        case productPurchaseFailed = 1006
        case refreshReceiptFailed = 1010
        case receiveRestoredTransactionsFailed = 1011

        /// Adapty SDK is not activated.
        case notActivated = 2002
        case badRequest = 2003
        case serverError = 2004
        case networkFailed = 2005
        case decodingFailed = 2006
        case encodingFailed = 2009

        case analyticsDisabled = 3000

        /// Wrong parameter was passed.
        case wrongParam = 3001

        /// It is not possible to call `.activate` method more than once.
        case activateOnceError = 3005

        /// The user profile was changed during the operation.
        case profileWasChanged = 3006
        case persistingDataError = 3100
        case operationInterrupted = 9000
    }
}

public struct AdaptyError: CustomNSError, CustomStringConvertible, CustomDebugStringConvertible {
    public static let errorDomain = AdaptyErrorDomain

    let wrapped: InternalAdaptyError

    public var description: String { wrapped.description }
    public var debugDescription: String { wrapped.debugDescription }

    public var originalError: Error? { wrapped.originalError }
    public var originalNSError: NSError? {
        guard let originalError = wrapped.originalError else { return nil }
        return originalError as NSError
    }

    public var adaptyErrorCode: ErrorCode { wrapped.adaptyErrorCode }
    public var errorCode: Int { wrapped.errorCode }
    public var errorUserInfo: [String: Any] { wrapped.errorUserInfo }
}

extension AdaptyError {
    static func activateOnceError(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        AdaptyError(wrapped: .activateOnceError(AdaptyError.Source(file: file, function: function, line: line)))
    }

    static func cantMakePayments(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        AdaptyError(wrapped: .cantMakePayments(AdaptyError.Source(file: file, function: function, line: line)))
    }

    static func notActivated(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        AdaptyError(wrapped: .notActivated(AdaptyError.Source(file: file, function: function, line: line)))
    }

    static func profileWasChanged(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        AdaptyError(wrapped: .profileWasChanged(AdaptyError.Source(file: file, function: function, line: line)))
    }

    static func decodingFallback(_ error: Error, file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        AdaptyError(wrapped: .decodingFailed(AdaptyError.Source(file: file, function: function, line: line),
                                             "Decoding Fallback Paywalls failed",
                                             error: error))
    }

    static func decodingPaywallProduct(_ error: Error, file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        AdaptyError(wrapped: .decodingFailed(AdaptyError.Source(file: file, function: function, line: line),
                                             "Decoding AdaptyPaywallProduct failed",
                                             error: error))
    }

    static func wrongParamOnboardingScreenOrder(file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        AdaptyError(wrapped: .wrongParam(AdaptyError.Source(file: file, function: function, line: line),
                                         "Wrong screenOrder parameter value, it should be more than zero."))
    }

    static func wrongKeyOfCustomAttribute(file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        AdaptyError(wrapped: .wrongParam(AdaptyError.Source(file: file, function: function, line: line),
                                         "The key must be string not more than 30 characters. Only letters, numbers, dashes, points and underscores allowed"))
    }

    static func wrongStringValueOfCustomAttribute(file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        AdaptyError(wrapped: .wrongParam(AdaptyError.Source(file: file, function: function, line: line),
                                         "The value must not be empty and not more than 30 characters."))
    }

    static func wrongCountCustomAttributes(file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        AdaptyError(wrapped: .wrongParam(AdaptyError.Source(file: file, function: function, line: line),
                                         "The total number of custom attributes must be no more than 10"))
    }

    static func cacheHasNotPaywall(file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        AdaptyError(wrapped: .persistingDataError(AdaptyError.Source(file: file, function: function, line: line),
                                                  "Don't found paywall in cache"))
    }
}

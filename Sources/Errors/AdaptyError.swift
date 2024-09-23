//
//  AdaptyError.swift
//  AdaptySDK
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

    public enum UserInfoKey {
        public static let description = NSDebugDescriptionErrorKey
        public static let source = "AdaptySourceErrorKey"
        public static let endpoint = "AdaptyHTTPEndpointErrorKey"
        public static let statusCode = "AdaptyHTTPStatusCodeErrorKey"
    }

    public enum ErrorCode: Int {

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
        case cantReadReceipt = 1005
        case productPurchaseFailed = 1006
        case refreshReceiptFailed = 1010

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
        case unsupportedData = 3007
        case fetchTimeoutError = 3101
        case operationInterrupted = 9000
    }
}

public struct AdaptyError: CustomNSError, CustomStringConvertible, CustomDebugStringConvertible {
    public static let errorDomain = AdaptyErrorDomain

    let wrapped: CustomAdaptyError

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

    public init(_ wrapped: CustomAdaptyError) {
        self.wrapped = wrapped
    }
}

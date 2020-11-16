//
//  Errors.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 12.11.2020.
//

import Foundation
import StoreKit

public class AdaptyError: NSError {
    
    @objc public var originalError: Error?
    @objc public var storeErrorCode: StoreErrorCode = .none
    @objc public var networkErrorCode: NetworkErrorCode = .none
    
    private let adaptyDomain = "com.adapty.AdaptySDK"
    
    init(with error: Error) {
        self.originalError = error
        
        if let error = error as? SKError {
            self.storeErrorCode = StoreErrorCode(rawValue: error.code.rawValue) ?? .none
        }
        
        let error = error as NSError
        super.init(domain: error.domain, code: error.code, userInfo: error.userInfo)
    }
    
    init(code: Int, storeCode: StoreErrorCode = .none, networkCode: NetworkErrorCode = .none, message: String) {
        self.storeErrorCode = storeCode
        self.networkErrorCode = networkCode
        super.init(domain: adaptyDomain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    init(code: StoreErrorCode, message: String) {
        self.storeErrorCode = code
        super.init(domain: adaptyDomain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    init(code: NetworkErrorCode, message: String) {
        self.networkErrorCode = code
        super.init(domain: adaptyDomain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public enum StoreErrorCode: Int {
        case none = -1
        
        // system
        case unknown = 0
        case clientInvalid = 1 // client is not allowed to issue the request, etc.
        case paymentCancelled = 2 // user cancelled the request, etc.
        case paymentInvalid = 3 // purchase identifier was invalid, etc.
        case paymentNotAllowed = 4 // this device is not allowed to make the payment
        case storeProductNotAvailable = 5 // Product is not available in the current storefront
        case cloudServicePermissionDenied = 6 // user has not allowed access to cloud service information
        case cloudServiceNetworkConnectionFailed = 7 // the device could not connect to the nework
        case cloudServiceRevoked = 8 // user has revoked permission to use this cloud service
        case privacyAcknowledgementRequired = 9 // The user needs to acknowledge Apple's privacy policy
        case unauthorizedRequestData = 10 // The app is attempting to use SKPayment's requestData property, but does not have the appropriate entitlement
        case invalidOfferIdentifier = 11 // The specified subscription offer identifier is not valid
        case invalidSignature = 12 // The cryptographic signature provided is not valid
        case missingOfferParams = 13 // One or more parameters from SKPaymentDiscount is missing
        case invalidOfferPrice = 14
        
        // custom
        case noProductIDsFound = 1000 // No In-App Purchase product identifiers were found
        case noProductsFound = 1001 // No In-App Purchases were found
        case productRequestFailed = 1002 // Unable to fetch available In-App Purchase products at the moment
        case cantMakePayments = 1003 // In-App Purchases are not allowed on this device
        case noPurchasesToRestore = 1004 // No purchases to restore
        case cantReadReceipt = 1005 // Can't find a valid receipt
        case productPurchaseFailed = 1006 // Product purchase failed
        case missingOfferSigningParams = 1007 // Missing offer signing required params
        case fallbackPaywallsNotRequired = 1008 // Fallback paywalls are not required
    }
    
    @objc public enum NetworkErrorCode: Int {
        case none = -1
        
        case emptyResponse = 0 //Response is empty
        case emptyData = 1 // Request data is empty
        case authenticationError = 2 // You need to be authenticated first
        case badRequest = 4 // Bad request
        case outdated = 5 // The url you requested is outdated
        case failed = 6 // Network request failed
        case unableToDecode = 8 // We could not decode the response
        case missingParam = 10 // Missing some of the required params
        case invalidProperty = 11 // Received invalid property data
        case encodingFailed = 12 // Parameters encoding failed
        case missingURL = 13 // Request url is nil
    }
    
    // network shortcuts
    class var emptyResponse: AdaptyError { return AdaptyError(code: NetworkErrorCode.emptyResponse, message: "Response is empty.") }
    class var emptyData: AdaptyError { return AdaptyError(code: NetworkErrorCode.emptyData, message: "Request data is empty.") }
    class var authenticationError: AdaptyError { return AdaptyError(code: NetworkErrorCode.authenticationError, message: "You need to be authenticated first.") }
    class var badRequest: AdaptyError { return AdaptyError(code: NetworkErrorCode.badRequest, message: "Bad request.") }
    class var outdated: AdaptyError { return AdaptyError(code: NetworkErrorCode.outdated, message: "The url you requested is outdated.") }
    class var failed: AdaptyError { return AdaptyError(code: NetworkErrorCode.failed, message: "Network request failed.") }
    class var unableToDecode: AdaptyError { return AdaptyError(code: NetworkErrorCode.unableToDecode, message: "We could not decode the response.") }
    class func missingParam(_ params: String) -> AdaptyError {
        return AdaptyError(code: NetworkErrorCode.missingParam, message: "Missing some of the required params: `\(params)`")
    }
    class func invalidProperty(_ property: String, _ data: Any) -> AdaptyError {
        return AdaptyError(code: NetworkErrorCode.invalidProperty, message: "Received invalid `\(property)`: `\(data)`")
    }
    class var encodingFailed: AdaptyError { return AdaptyError(code: NetworkErrorCode.encodingFailed, message: "Parameters encoding failed.") }
    class var missingURL: AdaptyError { return AdaptyError(code: NetworkErrorCode.missingURL, message: "Request url is nil.") }
    
    // store shortcuts
    class var noProductIDsFound: AdaptyError { return AdaptyError(code: StoreErrorCode.noProductIDsFound, message: "No In-App Purchase product identifiers were found.") }
    class var noProductsFound: AdaptyError { return AdaptyError(code: StoreErrorCode.noProductsFound, message: "No In-App Purchases were found.") }
    class var productRequestFailed: AdaptyError { return AdaptyError(code: StoreErrorCode.productRequestFailed, message: "Unable to fetch available In-App Purchase products at the moment.") }
    class var cantMakePayments: AdaptyError { return AdaptyError(code: StoreErrorCode.cantMakePayments, message: "In-App Purchases are not allowed on this device.") }
    class var noPurchasesToRestore: AdaptyError { return AdaptyError(code: StoreErrorCode.noPurchasesToRestore, message: "No purchases to restore.") }
    class var cantReadReceipt: AdaptyError { return AdaptyError(code: StoreErrorCode.cantReadReceipt, message: "Can't find a valid receipt.") }
    class var productPurchaseFailed: AdaptyError { return AdaptyError(code: StoreErrorCode.productPurchaseFailed, message: "Product purchase failed.") }
    class var missingOfferSigningParams: AdaptyError { return AdaptyError(code: StoreErrorCode.missingOfferSigningParams, message: "Missing offer signing required params.") }
    class var fallbackPaywallsNotRequired: AdaptyError { return AdaptyError(code: StoreErrorCode.fallbackPaywallsNotRequired, message: "Fallback paywalls are not required.") }
    
}

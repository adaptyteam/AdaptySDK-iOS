//
//  Adapty.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol AdaptyDelegate: class {
    
    func didReceiveUpdatedPurchaserInfo(_ purchaserInfo: PurchaserInfoModel)
    
}

@objc public class Adapty: NSObject {
    
    private static let shared = Adapty()
    private var profileId: String = DefaultsManager.shared.profileId {
        didSet {
            DefaultsManager.shared.profileId = profileId
        }
    }
    private var purchaserInfo: PurchaserInfoModel? = DefaultsManager.shared.purchaserInfo {
        didSet {
            if let profileId = purchaserInfo?.profileId {
                self.profileId = profileId
            } else {
                self.profileId = UserProperties.uuid
            }
            
            DefaultsManager.shared.purchaserInfo = purchaserInfo
            
            if let purchaserInfo = purchaserInfo, purchaserInfo != oldValue {
                Self.delegate?.didReceiveUpdatedPurchaserInfo(purchaserInfo)
            }
        }
    }
    private var installation: InstallationModel? = DefaultsManager.shared.installation {
        didSet {
            DefaultsManager.shared.installation = installation
        }
    }
    private lazy var apiManager: ApiManager = {
        return ApiManager()
    }()
    private lazy var sessionsManager: SessionsManager = {
        return SessionsManager()
    }()
    private lazy var iapManager: IAPManager = {
        return IAPManager(apiManager: apiManager)
    }()
    private var isConfigured = false
    private static var initialCustomerUserId: String?
    static var observerMode = false
    
    @objc public static weak var delegate: AdaptyDelegate?
    
    override private init() {
        super.init()
    }
    
    @objc public class func activate(_ apiKey: String) {
        activate(apiKey, observerMode: false, customerUserId: nil)
    }
    
    @objc public class func activate(_ apiKey: String, observerMode: Bool) {
        activate(apiKey, observerMode: observerMode, customerUserId: nil)
    }
    
    @objc public class func activate(_ apiKey: String, customerUserId: String?) {
        activate(apiKey, observerMode: false, customerUserId: customerUserId)
    }
    
    @objc public class func activate(_ apiKey: String, observerMode: Bool, customerUserId: String?) {
        activate(apiKey, observerMode: observerMode, customerUserId: customerUserId, completion: nil)
    }
    
    @objc public class func activate(_ apiKey: String, observerMode: Bool, customerUserId: String?, completion: ErrorCompletion? = nil) {
        Constants.APIKeys.secretKey = apiKey
        self.observerMode = observerMode
        self.initialCustomerUserId = customerUserId
        shared.configure(completion)
    }
    
    private func configure(_ completion: ErrorCompletion? = nil) {
        if isConfigured { return }
        isConfigured = true
        
        if purchaserInfo == nil {
            // didn't find synced profile, sync a local one and perform initial requests right after
            createProfile(Self.initialCustomerUserId, completion)
        } else {
            // already have a synced profile
            // update local cache for purchaser info
            Self.getPurchaserInfo { (_, _, _) in }
            // perform initial requests
            performInitialRequests()
            completion?(nil)
        }
        
        AppDelegateSwizzler.startSwizzlingIfPossible(self)
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] (_) in
            self?.sessionsManager.trackLiveEventInBackground()
        }
    }
    
    private func performInitialRequests() {
        // sync installation data and receive cognito credentials
        syncInstallation { _, _ in
            // start live tracking
            self.sessionsManager.startTrackingLiveEvent()
        }
        
        // start observing purchases
        iapManager.startObservingPurchases()
    }
    
    //MARK: - REST
    
    private func createProfile(_ customerUserId: String?, _ completion: ErrorCompletion? = nil) {
        var attributes = Parameters()
        
        if let idfa = UserProperties.idfa { attributes["idfa"] = idfa }
        if let customerUserId = customerUserId { attributes["customer_user_id"] = customerUserId }
        
        let params = Parameters.formatData(with: profileId, type: Constants.TypeNames.profile, attributes: attributes)
        
        apiManager.createProfile(id: profileId, params: params) { (purchaserInfo, error, isNew) in
            if let purchaserInfo = purchaserInfo {
                // do not overwrite in case of error
                self.purchaserInfo = purchaserInfo
            }
            
            completion?(error)
            
            if error == nil {
                self.performInitialRequests()
                
                // sync latest receipt to server and obtain eligibility criteria for introductory and promotional offers
                self.syncTransactionsHistory()
            }
        }
    }
    
    @objc public class func identify(_ customerUserId: String, completion: ErrorCompletion? = nil) {
        if shared.purchaserInfo?.customerUserId == customerUserId {
            completion?(nil)
            return
        }
        
        shared.createProfile(customerUserId, completion)
    }
    
    @objc public class func updateProfile(
        email: String? = nil,
        phoneNumber: String? = nil,
        facebookUserId: String? = nil,
        amplitudeUserId: String? = nil,
        mixpanelUserId: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        gender: String? = nil,
        birthday: Date? = nil,
        completion: ErrorCompletion? = nil)
    {
        let profileId = shared.profileId
        
        var attributes = Parameters()
        
        if let email = email { attributes["email"] = email }
        if let phoneNumber = phoneNumber { attributes["phone_number"] = phoneNumber }
        if let facebookUserId = facebookUserId { attributes["facebook_user_id"] = facebookUserId }
        if let amplitudeUserId = amplitudeUserId { attributes["amplitude_user_id"] = amplitudeUserId }
        if let mixpanelUserId = mixpanelUserId { attributes["mixpanel_user_id"] = mixpanelUserId }
        if let firstName = firstName { attributes["first_name"] = firstName }
        if let lastName = lastName { attributes["last_name"] = lastName }
        if let gender = gender { attributes["gender"] = gender }
        if let birthday = birthday { attributes["birthday"] = birthday.stringValue }
        if let idfa = UserProperties.idfa { attributes["idfa"] = idfa }
        
        let params = Parameters.formatData(with: profileId, type: Constants.TypeNames.profile, attributes: attributes)
        
        shared.apiManager.updateProfile(id: profileId, params: params) { (params, error) in
            completion?(error)
        }
    }
    
    private func syncInstallation(_ completion: InstallationCompletion? = nil) {
        let installationMetaId = installation?.profileInstallationMetaId ?? UserProperties.staticUuid

        var attributes = Parameters()
        
        if let sdkVersion = UserProperties.sdkVersion { attributes["adapty_sdk_version"] = sdkVersion }
        attributes["adapty_sdk_version_build"] = UserProperties.sdkVersionBuild
        if let appBuild = UserProperties.appBuild { attributes["app_build"] = appBuild }
        if let appVersion = UserProperties.appVersion { attributes["app_version"] = appVersion }
        attributes["device"] = UserProperties.device
        attributes["locale"] = UserProperties.locale
        attributes["os"] = UserProperties.OS
        attributes["platform"] = UserProperties.platform
        attributes["timezone"] = UserProperties.timezone
        if let deviceIdentifier = UserProperties.deviceIdentifier { attributes["device_identifier"] = deviceIdentifier }
        if let apnsTokenString = apnsTokenString { attributes["device_token"] = apnsTokenString }
        
        #warning("Handle Adjust params")
        
        let params = Parameters.formatData(with: installationMetaId, type: Constants.TypeNames.installation, attributes: attributes)
        
        apiManager.syncInstallation(id: installationMetaId, profileId: profileId, params: params) { (installation, error) in
            if let installation = installation {
                // do not overwrite in case of error
                self.installation = installation
            }
            completion?(installation, error)
        }
    }
    
    @objc public class func updateAttribution(_ attribution: NSObject?, completion: ErrorCompletion? = nil) {
        let installationMetaId = shared.installation?.profileInstallationMetaId ?? UserProperties.staticUuid
        
        var attributes = Parameters()

        if let network = attribution?.value(forKey: "network") { attributes["attribution_network"] = network }
        if let campaign = attribution?.value(forKey: "campaign") { attributes["attribution_campaign"] = campaign }
        if let trackerToken = attribution?.value(forKey: "trackerToken") { attributes["attribution_tracker_token"] = trackerToken }
        if let trackerName = attribution?.value(forKey: "trackerName") { attributes["attribution_tracker_name"] = trackerName }
        if let adgroup = attribution?.value(forKey: "adgroup") { attributes["attribution_adgroup"] = adgroup }
        if let creative = attribution?.value(forKey: "creative") { attributes["attribution_creative"] = creative }
        if let clickLabel = attribution?.value(forKey: "clickLabel") { attributes["attribution_click_label"] = clickLabel }
        if let adid = attribution?.value(forKey: "adid") { attributes["attribution_adid"] = adid }
        
        let params = Parameters.formatData(with: installationMetaId, type: Constants.TypeNames.installation, attributes: attributes)
        
        shared.apiManager.syncInstallation(id: installationMetaId, profileId: shared.profileId, params: params) { (installation, error) in
            if let installation = installation {
                // do not overwrite in case of error
                shared.installation = installation
            }
            completion?(error)
        }
    }
    
    @objc public class func getPurchaseContainers(_ completion: @escaping PurchaseContainersCompletion) {
        shared.iapManager.getPurchaseContainers(completion)
    }
    
    @objc public class func makePurchase(product: ProductModel, offerId: String? = nil, completion: @escaping BuyProductCompletion) {
        shared.iapManager.makePurchase(product: product, offerId: offerId, completion: completion)
    }
    
    @objc public class func restorePurchases(completion: @escaping ErrorCompletion) {
        shared.iapManager.restorePurchases(completion)
    }
    
    @objc public class func validateReceipt(_ receiptEncoded: String, variationId: String? = nil, vendorProductId: String? = nil, transactionId: String? = nil, originalPrice: NSDecimalNumber? = nil, discountPrice: NSDecimalNumber? = nil, priceLocale: Locale? = nil, completion: @escaping ValidateReceiptCompletion) {
        var attributes = Parameters()
        
        attributes["profile_id"] = shared.profileId
        attributes["receipt_encoded"] = receiptEncoded
        if let variationId = variationId { attributes["variation_id"] = variationId }
        if let vendorProductId = vendorProductId { attributes["vendor_product_id"] = vendorProductId }
        if let transactionId = transactionId { attributes["transaction_id"] = transactionId }
        if let originalPrice = originalPrice { attributes["original_price"] = originalPrice.stringValue }
        if let discountPrice = discountPrice { attributes["discount_price"] = discountPrice.stringValue }
        if let priceLocale = priceLocale {
            attributes["price_locale"] = priceLocale.currencyCode
            attributes["store_country"] = priceLocale.regionCode
        }
        
        let params = Parameters.formatData(with: "", type: Constants.TypeNames.appleReceipt, attributes: attributes)
        
        shared.apiManager.validateReceipt(params: params) { (purchaserInfo, appleValidationResult, error) in
            if let purchaserInfo = purchaserInfo {
                // do not overwrite in case of error
                shared.purchaserInfo = purchaserInfo
            }
            
            completion(purchaserInfo, appleValidationResult, error)
        }
    }
    
    @objc public static var apnsToken: Data? {
        didSet {
            shared.apnsTokenString = apnsToken?.map { String(format: "%02.2hhx", $0) }.joined()
        }
    }
    
    private var apnsTokenString: String? {
        didSet {
            syncInstallation()
        }
    }
    
    @objc public class var customerUserId: String? {
        return shared.purchaserInfo?.customerUserId
    }
    
    private func syncTransactionsHistory() {
        guard let receipt = iapManager.latestReceipt else {
            return
        }
        
        Self.validateReceipt(receipt) { _, _, _  in
        }
    }
    
    @objc public class func getPurchaserInfo(_ completion: @escaping CahcedPurchaserCompletion) {
        let cachedPurchaserInfo = shared.purchaserInfo
        
        if cachedPurchaserInfo != nil {
            completion(cachedPurchaserInfo, .cached, nil)
        }
        
        shared.apiManager.getPurchaserInfo(id: shared.profileId) { (purchaserInfo, error) in
            if let purchaserInfo = purchaserInfo {
                shared.purchaserInfo = purchaserInfo
            }
            
            completion(purchaserInfo, .synced, error)
        }
    }
    
    @objc public class func logout(_ completion: ErrorCompletion? = nil) {
        shared.sessionsManager.invalidateLiveTrackerTimer()
        shared.purchaserInfo = nil
        shared.installation = nil
        DefaultsManager.shared.clean()
        
        // automatically create new profile
        shared.createProfile(nil, completion)
    }
    
}

extension Adapty: AppDelegateSwizzlerDelegate {
    
    func didReceiveAPNSToken(_ deviceToken: Data) {
        Self.apnsToken = deviceToken
    }
    
}

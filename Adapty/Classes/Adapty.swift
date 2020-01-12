//
//  Adapty.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation
import UIKit

@objc public class Adapty: NSObject {
    
    private static let shared = Adapty()
    private var profile: ProfileModel? = DefaultsManager.shared.profile {
        didSet {
            DefaultsManager.shared.profile = profile
        }
    }
    private var installation: InstallationModel? = DefaultsManager.shared.installation {
        didSet {
            DefaultsManager.shared.installation = installation
        }
    }
    private lazy var apiManager: ApiManager = {
        return ApiManager.shared
    }()
    private lazy var sessionsManager: SessionsManager = {
        return SessionsManager()
    }()
    private lazy var iapManager: IAPManager = {
        return IAPManager()
    }()
    
    override private init() {
        super.init()
    }
    
    @objc public class func activate(_ apiKey: String) {
        Constants.APIKeys.secretKey = apiKey
        shared.configure()
    }
    
    private func configure() {
        AppDelegateSwizzler.startSwizzlingIfPossible(self)
        
        iapManager.startObservingPurchases()
        
        if profile == nil {
            // didn't find existing profile, create a new one and perform initial requests right after
            createProfile()
        } else {
            // already have a profile, just perform initial requests
            performInitialRequests()
        }
        
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
        
        // sync latest receipt to server and obtain eligibility criteria for introductory and promotional offers
        syncTransactionsHistory()
    }
    
    //MARK: - REST
    
    private func createProfile(_ completion: ErrorCompletion? = nil) {
        if profile != nil {
            completion?(NetworkResponse.alreadyAuthenticatedError)
            return
        }
        
        var params = Parameters()
        
        if let idfa = UserProperties.idfa { params["idfa"] = idfa }
        params["profile_id"] = UserProperties.staticUuid
        
        apiManager.createProfile(params: params) { (profile, error, isNew) in
            self.profile = profile
            completion?(error)
            
            if error == nil {
                self.performInitialRequests()
            }
        }
    }
    
    @objc public class func updateProfile(
        customerUserId: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        facebookUserId: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        gender: String? = nil,
        birthday: Date? = nil,
        completion: ErrorCompletion? = nil)
    {
        guard let profileId = shared.profile?.profileId else {
            completion?(NetworkResponse.missingRequiredParams)
            return
        }
        
        var params = Parameters()
        
        if let customerUserId = customerUserId { params["customer_user_id"] = customerUserId }
        if let email = email { params["email"] = email }
        if let phoneNumber = phoneNumber { params["phone_number"] = phoneNumber }
        if let facebookUserId = facebookUserId { params["facebook_user_id"] = facebookUserId }
        if let firstName = firstName { params["first_name"] = firstName }
        if let lastName = lastName { params["last_name"] = lastName }
        if let gender = gender { params["gender"] = gender }
        if let birthday = birthday { params["birthday"] = birthday.stringValue }
        if let idfa = UserProperties.idfa { params["idfa"] = idfa }
        
        shared.apiManager.updateProfile(id: profileId, params: params) { (profile, error) in
            if let profile = profile {
                // do not overwrite in case of error
                shared.profile = profile
            }
            completion?(error)
        }
    }
    
    private func syncInstallation(_ completion: InstallationCompletion? = nil) {
        guard let profileId = profile?.profileId else {
            completion?(nil, NetworkResponse.missingRequiredParams)
            return
        }
        
        var params = Parameters()
        
        params["profile_id"] = profileId
        params["profile_installation_meta_id"] = installation?.profileInstallationMetaId ?? UserProperties.uuid
        if let sdkVersion = UserProperties.sdkVersion { params["adapty_sdk_version"] = sdkVersion }
        params["adapty_sdk_version_build"] = UserProperties.sdkVersionBuild
        if let appBuild = UserProperties.appBuild { params["app_build"] = appBuild }
        if let appVersion = UserProperties.appVersion { params["app_version"] = appVersion }
        params["device"] = UserProperties.device
        params["locale"] = UserProperties.locale
        params["os"] = UserProperties.OS
        params["platform"] = UserProperties.platform
        params["timezone"] = UserProperties.timezone
        if let deviceIdentifier = UserProperties.deviceIdentifier { params["device_identifier"] = deviceIdentifier }
        if let apnsTokenString = apnsTokenString { params["device_token"] = apnsTokenString }
        
        #warning("Handle Adjust params")
        
        apiManager.syncInstallation(params: params) { (installation, error) in
            if let installation = installation {
                // do not overwrite in case of error
                self.installation = installation
            }
            completion?(installation, error)
        }
    }
    
    @objc public class func updateAdjustAttribution(_ attribution: NSObject?, completion: ErrorCompletion? = nil) {
        guard let profileId = shared.profile?.profileId, let installationMetaId = shared.installation?.profileInstallationMetaId else {
            completion?(NetworkResponse.missingRequiredParams)
            return
        }
        
        var params = Parameters()
        
        params["profile_id"] = profileId
        params["profile_installation_meta_id"] = installationMetaId
        if let trackerToken = attribution?.value(forKey: "trackerToken") { params["attribution_tracker_token"] = trackerToken }
        if let trackerName = attribution?.value(forKey: "trackerName") { params["attribution_tracker_name"] = trackerName }
        if let network = attribution?.value(forKey: "network") { params["attribution_network"] = network }
        if let campaign = attribution?.value(forKey: "campaign") { params["attribution_campaign"] = campaign }
        if let adgroup = attribution?.value(forKey: "adgroup") { params["attribution_adgroup"] = adgroup }
        if let creative = attribution?.value(forKey: "creative") { params["attribution_creative"] = creative }
        if let clickLabel = attribution?.value(forKey: "clickLabel") { params["attribution_click_label"] = clickLabel }
        if let adid = attribution?.value(forKey: "adid") { params["attribution_adid"] = adid }
        
        shared.apiManager.syncInstallation(params: params) { (installation, error) in
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
    
    @objc public class func validateReceipt(_ receiptEncoded: String, variationId: String? = nil, originalPrice: NSDecimalNumber? = nil, discountPrice: NSDecimalNumber? = nil, priceLocale: Locale? = nil, completion: @escaping JSONCompletion) {
        guard let id = shared.profile?.profileId else {
            completion(nil, NetworkResponse.missingRequiredParams)
            return
        }
        
        var params = ["profile_id": id, "receipt_encoded": receiptEncoded]
        if let variationId = variationId { params["variation_id"] = variationId }
        if let originalPrice = originalPrice { params["original_price"] = originalPrice.stringValue }
        if let discountPrice = discountPrice { params["discount_price"] = discountPrice.stringValue }
        if let priceLocale = priceLocale { params["price_locale"] = priceLocale.currencyCode }
        
        shared.apiManager.validateReceipt(params: params, completion: completion)
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
        return shared.profile?.customerUserId
    }
    
    private func syncTransactionsHistory() {
        guard let receipt = iapManager.latestReceipt else {
            return
        }
        
        Self.validateReceipt(receipt) { _,_  in
#warning("sync eligibility criteria for user")
        }
    }
    
    @objc public class func logout() {
        shared.sessionsManager.invalidateLiveTrackerTimer()
        shared.profile = nil
        shared.installation = nil
        DefaultsManager.shared.clean()
        
        // automatically create new profile
        shared.createProfile()
    }
    
}

extension Adapty: AppDelegateSwizzlerDelegate {
    
    func didReceiveAPNSToken(_ deviceToken: Data) {
        Self.apnsToken = deviceToken
    }
    
}

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
    func didReceivePromo(_ promo: PromoModel)
    @objc optional func paymentQueue(shouldAddStorePaymentFor product: ProductModel, defermentCompletion makeDeferredPurchase: @escaping DeferredPurchaseCompletion)
    
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
            LoggerManager.logMessage("Updating local purchaserInfo: \(String(describing: purchaserInfo)), with profileId: \(String(describing: purchaserInfo?.profileId)), customerUserId: \(String(describing: purchaserInfo?.customerUserId))")
            
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
    private var promo: PromoModel? {
        didSet {
            if let promo = promo, promo != oldValue {
                Self.delegate?.didReceivePromo(promo)
            }
        }
    }
    private lazy var apiManager: ApiManager = {
        return ApiManager()
    }()
    private lazy var sessionsManager: SessionsManager = {
        return SessionsManager()
    }()
    private lazy var kinesisManager: KinesisManager = {
        return KinesisManager.shared
    }()
    private lazy var iapManager: IAPManager = {
        return IAPManager(apiManager: apiManager)
    }()
    private var isConfigured = false
    private static var initialCustomerUserId: String?
    static var observerMode = false
    
    @objc public static weak var delegate: AdaptyDelegate?
    @objc public static var logLevel: AdaptyLogLevel = LoggerManager.logLevel {
        didSet {
            LoggerManager.logLevel = logLevel
        }
    }
    
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
        Constants.APIKeys.secretKey = apiKey
        self.observerMode = observerMode
        self.initialCustomerUserId = customerUserId
        shared.configure()
    }
    
    private func configure() {
        if isConfigured { return }
        isConfigured = true
        
        if purchaserInfo == nil {
            // didn't find synced profile, sync a local one and perform initial requests right after
            createProfile(Self.initialCustomerUserId)
        } else {
            // already have a synced profile
            // update local cache for purchaser info
            Self.getPurchaserInfo { (_, _, _) in }
            // perform initial requests
            performInitialRequests()
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
        iapManager.startObservingPurchases { (_, _, _) in
            // get current existing promo
            Self.getPromo()
        }
        
        // check if user enabled apple search ads attribution collection
        if let appleSearchAdsAttributionCollectionEnabled = Bundle.main.infoDictionary?[Constants.BundleKeys.appleSearchAdsAttributionCollectionEnabled] as? Bool, appleSearchAdsAttributionCollectionEnabled {
            updateAppleSearchAdsAttribution()
        }
    }
    
    //MARK: - REST
    
    private func createProfile(_ customerUserId: String?, _ completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        var attributes = Parameters()
        
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
        
        LoggerManager.logMessage("Calling now: \(#function)")
        
        shared.createProfile(customerUserId, completion)
    }
    
    @objc public class func updateProfile(params: ProfileParameterBuilder, completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        let profileId = shared.profileId

        let params = Parameters.formatData(with: profileId, type: Constants.TypeNames.profile, attributes: params.toDictionary())
        
        shared.apiManager.updateProfile(id: profileId, params: params) { (params, error) in
            completion?(error)
        }
    }
    
    private func syncInstallation(_ completion: InstallationCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
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
        if let deviceIdentifier = UserProperties.deviceIdentifier { attributes["idfv"] = deviceIdentifier }
        if let apnsTokenString = apnsTokenString { attributes["device_token"] = apnsTokenString }
        if let idfa = UserProperties.idfa { attributes["idfa"] = idfa }
        
        let params = Parameters.formatData(with: installationMetaId, type: Constants.TypeNames.installation, attributes: attributes)
        
        apiManager.syncInstallation(id: installationMetaId, profileId: profileId, params: params) { (installation, error) in
            if let installation = installation {
                // do not overwrite in case of error
                self.installation = installation
            }
            completion?(installation, error)
        }
    }
    
    private func updateAppleSearchAdsAttribution() {
        UserProperties.appleSearchAdsAttribution { (attribution, error) in
            if let attribution = attribution,
                let values = attribution.values.map({ $0 }).first as? Parameters,
                let iAdAttribution = values["iad-attribution"] as? NSString,
                // check if the user clicked an Apple Search Ads impression up to 30 days before app download
                iAdAttribution.boolValue == true,
                // check if this is an actual first sync
                DefaultsManager.shared.appleSearchAdsSyncDate == nil
            {
                Self.updateAttribution(attribution, source: .appleSearchAds)
            }
        }
    }
    
    @objc public class func updateAttribution(_ attribution: [AnyHashable: Any], source: AttributionNetwork, networkUserId: String? = nil, completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        var attributes = Parameters()
        
        switch source {
        case .adjust:
            attributes["source"] = "adjust"
        case .appsflyer:
            attributes["source"] = "appsflyer"
        case .branch:
            attributes["source"] = "branch"
        case .appleSearchAds:
            attributes["source"] = "apple_search_ads"
        case .custom:
            attributes["source"] = "custom"
        }
        
        if let networkUserId = networkUserId { attributes["network_user_id"] = networkUserId }
        attributes["attribution"] = attribution
        
        let params = Parameters.formatData(with: shared.profileId, type: Constants.TypeNames.profileAttribution, attributes: attributes)
        
        shared.apiManager.updateAttribution(id: shared.profileId, params: params) { (_, error) in
            if source == .appleSearchAds && error == nil {
                // mark appleSearchAds attribution data as synced
                DefaultsManager.shared.appleSearchAdsSyncDate = Date()
            }
            completion?(error)
        }
    }
    
    @objc public class func getPaywalls(_ completion: @escaping CachedPaywallsCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        let paywalls = shared.iapManager.paywalls
        let products = shared.iapManager.products
        if paywalls != nil || products != nil {
            completion(paywalls, products, .cached, nil)
        }
        
        shared.iapManager.getPaywalls { (paywalls, products, error) in
            completion(paywalls, products, .synced, error)
        }
    }
    
    @objc public class func makePurchase(product: ProductModel, offerId: String? = nil, completion: @escaping BuyProductCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        shared.iapManager.makePurchase(product: product, offerId: offerId) { (purchaserInfo, receipt, appleValidationResult, product, error) in
            if let error = error {
                LoggerManager.logError("Failed to purchase product: \(product?.vendorProductId ?? "")\n\(error.localizedDescription)")
            } else {
                LoggerManager.logMessage("Successfully purchased product: \(product?.vendorProductId ?? "")")
            }
            
            completion(purchaserInfo, receipt, appleValidationResult, product, error)
        }
    }
    
    @objc public class func restorePurchases(completion: @escaping RestorePurchasesCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        shared.iapManager.restorePurchases(completion)
    }
    
    @objc public class func validateReceipt(_ receiptEncoded: String, completion: @escaping ValidateReceiptCompletion) {
        extendedValidateReceipt(receiptEncoded, completion: completion)
    }
    
    class func extendedValidateReceipt(_ receiptEncoded: String, variationId: String? = nil, vendorProductId: String? = nil, transactionId: String? = nil, originalPrice: Decimal? = nil, discountPrice: Decimal? = nil, currencyCode: String? = nil, regionCode: String? = nil, promotionalOfferId: String? = nil, unit: String? = nil, numberOfUnits: Int? = nil, paymentMode: String? = nil, completion: @escaping ValidateReceiptCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        var attributes = Parameters()
        
        attributes["profile_id"] = shared.profileId
        attributes["receipt_encoded"] = receiptEncoded
        if let variationId = variationId { attributes["variation_id"] = variationId }
        if let vendorProductId = vendorProductId { attributes["vendor_product_id"] = vendorProductId }
        if let transactionId = transactionId { attributes["transaction_id"] = transactionId }
        if let originalPrice = originalPrice { attributes["original_price"] = originalPrice }
        if let discountPrice = discountPrice { attributes["discount_price"] = discountPrice }
        if let currencyCode = currencyCode { attributes["price_locale"] = currencyCode }
        if let regionCode = regionCode { attributes["store_country"] = regionCode }
        
        if let promotionalOfferId = promotionalOfferId { attributes["promotional_offer_id"] = promotionalOfferId }
        var offer = Parameters()
        if let unit = unit { offer["period_unit"] = unit }
        if let numberOfUnits = numberOfUnits { offer["number_of_units"] = numberOfUnits }
        if let paymentMode = paymentMode { offer["type"] = paymentMode }
        if offer.count > 0 { attributes["offer"] = offer }
        
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
    
    @objc public static var apnsTokenString: String? {
        didSet {
            shared.apnsTokenString = apnsTokenString
        }
    }
    
    private var apnsTokenString: String? {
        didSet {
            LoggerManager.logMessage("Setting APNS token.")
            syncInstallation()
        }
    }
    
    @objc public class var customerUserId: String? {
        return shared.purchaserInfo?.customerUserId
    }
    
    private func syncTransactionsHistory() {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        iapManager.syncTransactionsHistory()
    }
    
    @objc public class func getPurchaserInfo(_ completion: @escaping CahcedPurchaserCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
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
    
    @objc public class func getPromo(_ completion: PromoCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        shared.apiManager.getPromo(id: shared.profileId) { (promo, error) in
            // match with locally stored paywall
            promo?.paywall = shared.iapManager.paywalls?.filter({ $0.variationId == promo?.variationId }).first
            
            // if there is no such paywall, re-sync them from server
            if let promo = promo, promo.paywall == nil {
                getPaywalls { (_, _, state, error) in
                    promo.paywall = shared.iapManager.paywalls?.filter({ $0.variationId == promo.variationId }).first
                    
                    shared.promo = promo
                    completion?(promo, error)
                }
                
                return
            }
            
            shared.promo = promo
            
            if let error = error, error.adaptyErrorCode == .missingParam {
                // do not return error in case of just empty response
                completion?(nil, nil)
                return
            }
            
            completion?(promo, error)
        }
    }
    
    @objc public class func handlePushNotification(_ userInfo: [AnyHashable : Any], completion: @escaping ErrorCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        guard let source = userInfo[Constants.NotificationPayload.source] as? String, source == "adapty" else {
            completion(nil)
            return
        }
        
        var params = [String: String]()
        if let promoDeliveryId = userInfo[Constants.NotificationPayload.promoDeliveryId] as? String {
            params[Constants.NotificationPayload.promoDeliveryId] = promoDeliveryId
        }
        
        shared.kinesisManager.trackEvent(.promoPushOpened, params: params)
        
        getPromo { (_, error) in
            completion(error)
        }
    }
    
    @discardableResult @objc
    public class func showPaywall(for paywall: PaywallModel, from viewController: UIViewController, delegate: AdaptyPaywallDelegate) -> PaywallViewController {
        let paywallViewController = getPaywall(for: paywall, delegate: delegate)
        viewController.present(paywallViewController, animated: true)
        return paywallViewController
    }
    
    @objc public class func getPaywall(for paywall: PaywallModel, delegate: AdaptyPaywallDelegate) -> PaywallViewController {
        let paywallViewController = PaywallViewController()
        paywallViewController.paywall = paywall
        paywallViewController.delegate = delegate
        paywallViewController.modalPresentationStyle = .fullScreen
        return paywallViewController
    }
    
    @objc public class func setFallbackPaywalls(_ paywalls: String, completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        shared.iapManager.setFallbackPaywalls(paywalls, completion: completion)
    }
    
    @objc public class func logout(_ completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")
        
        shared.sessionsManager.invalidateLiveTrackerTimer()
        shared.purchaserInfo = nil
        shared.installation = nil
        shared.promo = nil
        UserProperties.resetStaticUuid()
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

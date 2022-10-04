//
//  Adapty.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

@objc public protocol AdaptyDelegate: AnyObject {
    func didReceiveUpdatedPurchaserInfo(_ purchaserInfo: PurchaserInfoModel)
    @objc optional func paymentQueue(shouldAddStorePaymentFor
        product: ProductModel,
        defermentCompletion makeDeferredPurchase: @escaping DeferredPurchaseCompletion)
}

@objc public class Adapty: NSObject {
    private static let shared = Adapty()
    private var profileId: String = DefaultsManager.shared.profileId {
        didSet {
            DefaultsManager.shared.profileId = profileId
        }
    }

    private var isPurchaserInfoDelegateNotifiedAtLeastOnce = false
    private var purchaserInfo: PurchaserInfoModel? = DefaultsManager.shared.purchaserInfo {
        didSet {
            LoggerManager.logMessage("Updating local purchaserInfo: \(String(describing: purchaserInfo)), with profileId: \(String(describing: purchaserInfo?.profileId)), customerUserId: \(String(describing: purchaserInfo?.customerUserId))")

            if let profileId = purchaserInfo?.profileId {
                self.profileId = profileId
            } else {
                profileId = UserProperties.uuid
            }

            DefaultsManager.shared.purchaserInfo = purchaserInfo

            // notify delegate in case of a data change or at least once at launch
            if let purchaserInfo = purchaserInfo {
                if !isPurchaserInfoDelegateNotifiedAtLeastOnce || purchaserInfo != oldValue {
                    isPurchaserInfoDelegateNotifiedAtLeastOnce = true
                    Self.delegate?.didReceiveUpdatedPurchaserInfo(purchaserInfo)
                }
            }
        }
    }

    private var installation: InstallationModel? = DefaultsManager.shared.installation {
        didSet {
            DefaultsManager.shared.installation = installation
        }
    }

    private lazy var apiManager: ApiManager = {
        ApiManager()
    }()

    private lazy var sessionsManager: SessionsManager = {
        SessionsManager()
    }()

    private lazy var kinesisManager: KinesisManager = {
        KinesisManager.shared
    }()

    private lazy var iapManager: IAPManager = {
        IAPManager(apiManager: apiManager)
    }()

    private lazy var requestHashManager: RequestHashManager = {
        RequestHashManager.shared
    }()

    private var isConfigured = false
    private static var initialCustomerUserId: String?
    static var observerMode = false

    @objc public weak static var delegate: AdaptyDelegate?
    @objc public static var logLevel: AdaptyLogLevel = LoggerManager.logLevel {
        didSet {
            LoggerManager.logLevel = logLevel
        }
    }

    @objc public static var idfaCollectionDisabled: Bool = false

    override private init() {
        super.init()
    }

    @objc public static func activate(_ apiKey: String) {
        activate(apiKey, observerMode: false, customerUserId: nil)
    }

    @objc public static func activate(_ apiKey: String, observerMode: Bool) {
        activate(apiKey, observerMode: observerMode, customerUserId: nil)
    }

    @objc public static func activate(_ apiKey: String, customerUserId: String?) {
        activate(apiKey, observerMode: false, customerUserId: customerUserId)
    }

    @objc public static func activate(_ apiKey: String, observerMode: Bool, customerUserId: String?) {
        activate(apiKey, observerMode: observerMode, customerUserId: customerUserId, completion: nil)
    }

    @objc public static func activate(_ apiKey: String, observerMode: Bool, customerUserId: String?, completion: ErrorCompletion?) {
        API.secretKey = apiKey
        self.observerMode = observerMode
        initialCustomerUserId = customerUserId
        shared.configure(completion)
    }

    private func configure(_ completion: ErrorCompletion? = nil) {
        if isConfigured {
            DispatchQueue.main.async {
                completion?(nil)
            }
            return
        }
        isConfigured = true

        if purchaserInfo == nil {
            // didn't find synced profile, sync a local one and perform initial requests right after
            createProfile(Self.initialCustomerUserId, completion)
        } else {
            // already have a synced profile
            // update local cache for purchaser info
            // or create new profile
            if let customerId = Self.initialCustomerUserId, purchaserInfo?.customerUserId != customerId {
                Self.identify(customerId, completion: completion)
            } else {
                if let purchaserInfo = purchaserInfo {
                    Self.delegate?.didReceiveUpdatedPurchaserInfo(purchaserInfo)
                }

                Self.getPurchaserInfo { _, error in
                    completion?(error)
                }
                // sync device meta info so user will get into a correct segment
                syncInstallationAndStartTrackingLiveEvent()
                // perform initial requests
                performInitialRequests(isNewUser: false)
            }
        }
    }

    private func performInitialRequests(isNewUser: Bool) {
        // start observing purchases
        iapManager.startObservingPurchases(syncTransactions: isNewUser) { _, _ in }

        // start refreshing purchaser info in background
        sessionsManager.startUpdatingPurchaserInfo()

        #if os(iOS)
            // check if user enabled apple search ads attribution collection
            if let appleSearchAdsAttributionCollectionEnabled = Bundle.main.infoDictionary?[BundleKeys.appleSearchAdsAttributionCollectionEnabled] as? Bool, appleSearchAdsAttributionCollectionEnabled {
                updateAppleSearchAdsAttribution()
            }
        #endif
    }

    private func syncInstallationAndStartTrackingLiveEvent() {
        // sync installation data and receive cognito credentials
        syncInstallation { _, _ in
            // start live tracking
            self.sessionsManager.startTrackingLiveEvent()
        }
    }

    // MARK: - REST

    private func createProfile(_ customerUserId: String?, _ completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")

        var attributes = Parameters()

        if let customerUserId = customerUserId { attributes["customer_user_id"] = customerUserId }

        let params = Parameters.formatData(with: profileId, type: .profile, attributes: attributes)

        apiManager.createProfile(id: profileId, params: params) { purchaserInfo, error, _ in
            if let purchaserInfo = purchaserInfo {
                // do not overwrite in case of error
                self.purchaserInfo = purchaserInfo
                // sync device meta info so user will get into a correct segment
                self.syncInstallationAndStartTrackingLiveEvent()
            }

            completion?(error)

            if error == nil {
                // perform initial requests
                self.performInitialRequests(isNewUser: true)
            }
        }
    }

    @objc public static func identify(_ customerUserId: String, completion: ErrorCompletion? = nil) {
        if shared.purchaserInfo?.customerUserId == customerUserId {
            DispatchQueue.main.async {
                completion?(nil)
            }
            return
        }

        LoggerManager.logMessage("Calling now: \(#function)")

        shared.createProfile(customerUserId, completion)
    }

    @objc public static func updateProfile(params: ProfileParameterBuilder, completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")

        let profileId = shared.profileId

        let params = Parameters.formatData(with: profileId, type: .profile, attributes: params.toDictionary())

        // TODO: Think of a way how to move cache checker to the request manager
        if shared.requestHashManager.isPostHashExists(for: .updateProfile, params: params) {
            completion?(nil)
            return
        }

        shared.apiManager.updateProfile(id: profileId, params: params) { _, error in
            if error == nil {
                shared.requestHashManager.storePostHash(for: .updateProfile, params: params)
            }
            completion?(error)
        }
    }

    private func syncInstallation(_ completion: InstallationCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")

        let installationMetaId = installation?.profileInstallationMetaId ?? UserProperties.staticUuid

        var attributes = Parameters()

        attributes["adapty_sdk_version"] = Adapty.SDKVersion
        attributes["adapty_sdk_version_build"] = Adapty.SDKBuild
        if let appBuild = UserProperties.appBuild { attributes["app_build"] = appBuild }
        if let appVersion = UserProperties.appVersion { attributes["app_version"] = appVersion }
        attributes["device"] = UserProperties.device
        attributes["locale"] = UserProperties.locale
        attributes["os"] = UserProperties.OS
        attributes["platform"] = UserProperties.platform
        attributes["timezone"] = UserProperties.timezone
        if DefaultsManager.shared.externalAnalyticsDisabled != true {
            if let deviceIdentifier = UserProperties.deviceIdentifier { attributes["idfv"] = deviceIdentifier }
            if let idfa = UserProperties.idfa { attributes["idfa"] = idfa }
        }

        let formattedParameters: (_ attributes: Parameters) -> Parameters = { attributes in
            Parameters.formatData(with: installationMetaId,
                                  type: .installation,
                                  attributes: attributes)
        }

        let params: Parameters
        let originalParams = formattedParameters(attributes)

        // TODO: Think of a way how to move cache checker to the request manager
        if requestHashManager.isPostHashExists(for: .syncInstallation, params: originalParams) {
            // send empty body in case of unchanged data
            params = formattedParameters(Parameters())
        } else {
            params = originalParams
        }

        apiManager.syncInstallation(id: installationMetaId, profileId: profileId, params: params) { installation, error in
            if let installation = installation {
                // do not overwrite in case of error
                self.installation = installation

                // save original params to post request body cache
                self.requestHashManager.storePostHash(for: .syncInstallation, params: originalParams)
            }
            completion?(installation, error)
        }
    }

    #if os(iOS)
        private func updateAppleSearchAdsAttribution() {
            UserProperties.appleSearchAdsAttribution { attribution, _ in
                // check if this is an actual first sync
                guard let attribution = attribution, DefaultsManager.shared.appleSearchAdsSyncDate == nil else { return }

                func update(attribution: Parameters, asa: Bool) {
                    var attribution = attribution
                    attribution["asa-attribution"] = asa
                    Self.updateAttribution(attribution, source: .appleSearchAds)
                }

                if let values = attribution.values.map({ $0 }).first as? Parameters,
                   let iAdAttribution = values["iad-attribution"] as? NSString {
                    // check if the user clicked an Apple Search Ads impression up to 30 days before app download
                    if iAdAttribution.boolValue == true {
                        update(attribution: attribution, asa: false)
                    }
                } else {
                    update(attribution: attribution, asa: true)
                }
            }
        }
    #endif

    @objc public static func updateAttribution(_ attribution: [AnyHashable: Any], source: AttributionNetwork, networkUserId: String? = nil, completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")

        var attributes = Parameters()

        attributes["source"] = source.rawSource
        if source == .appsflyer {
            assert(networkUserId != nil, "`networkUserId` is required for AppsFlyer attributon, otherwise we won't be able to send specific events. You can get it by accessing `AppsFlyerLib.shared().getAppsFlyerUID()` or in a similar way according to the official SDK.")
        }

        if let networkUserId = networkUserId { attributes["network_user_id"] = networkUserId }
        attributes["attribution"] = attribution

        let params = Parameters.formatData(with: shared.profileId, type: .profileAttribution, attributes: attributes)
        // TODO: Think of a way how to move cache checker to the request manager
        if shared.requestHashManager.isPostHashExists(for: .updateAttribution, source: source, params: params) {
            completion?(nil)
            return
        }

        shared.apiManager.updateAttribution(id: shared.profileId, params: params) { _, error in
            if error == nil {
                shared.requestHashManager.storePostHash(for: .updateAttribution, source: source, params: params)
            }
            if source == .appleSearchAds && error == nil {
                // mark appleSearchAds attribution data as synced
                DefaultsManager.shared.appleSearchAdsSyncDate = Date()
            }
            completion?(error)
        }
    }

    @objc public static func getPaywall(_ id: String, _ completion: @escaping PaywallCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")

        shared.iapManager.getPaywall(id, completion)
    }

    @objc public static func getProducts(forceUpdate: Bool = false, _ completion: @escaping ProductsCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")

        shared.iapManager.getProducts(forceUpdate: forceUpdate, completion)
    }

    @objc public static func makePurchase(product: ProductModel, offerId: String? = nil, completion: @escaping BuyProductCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")

        shared.iapManager.makePurchase(product: product, offerId: offerId) { purchaserInfo, receipt, appleValidationResult, product, error in
            if let error = error {
                LoggerManager.logError("Failed to purchase product: \(product?.vendorProductId ?? "")\n\(error.localizedDescription)")
            } else {
                LoggerManager.logMessage("Successfully purchased product: \(product?.vendorProductId ?? "")")
            }

            completion(purchaserInfo, receipt, appleValidationResult, product, error)
        }
    }

    @objc public static func restorePurchases(completion: @escaping RestorePurchasesCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")

        shared.iapManager.restorePurchases(completion)
    }

    @objc static func validateReceipt(_ receiptEncoded: String, completion: @escaping ValidateReceiptCompletion) {
        extendedValidateReceipt(receiptEncoded, completion: completion)
    }

    static func extendedValidateReceipt(_ receiptEncoded: String, variationId: String? = nil, vendorProductId: String? = nil, transactionId: String? = nil, originalPrice: Decimal? = nil, discountPrice: Decimal? = nil, currencyCode: String? = nil, regionCode: String? = nil, promotionalOfferId: String? = nil, unit: String? = nil, numberOfUnits: Int? = nil, paymentMode: String? = nil, completion: @escaping ValidateReceiptCompletion) {
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

        let params = Parameters.formatData(with: "", type: .appleReceipt, attributes: attributes)

        shared.apiManager.validateReceipt(params: params) { purchaserInfo, appleValidationResult, error in
            if let purchaserInfo = purchaserInfo {
                // do not overwrite in case of error
                shared.purchaserInfo = purchaserInfo
            }

            completion(purchaserInfo, appleValidationResult, error)
        }
    }

    @objc public static var customerUserId: String? {
        return shared.purchaserInfo?.customerUserId
    }

    @objc public static func syncTransactionsHistory(completion: SyncTransactionsHistoryCompletion? = nil) {
        shared.syncTransactionsHistory(completion: completion)
    }

    private func syncTransactionsHistory(completion: SyncTransactionsHistoryCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")

        iapManager.syncTransactionsHistory(completion: completion)
    }

    @objc public static func getPurchaserInfo(forceUpdate: Bool = false, _ completion: @escaping PurchaserCompletion) {
        LoggerManager.logMessage("Calling now: \(#function)")

        let cachedPurchaserInfo = shared.purchaserInfo

        // call callback instantly with cached data
        if !forceUpdate, cachedPurchaserInfo != nil {
            DispatchQueue.main.async {
                completion(cachedPurchaserInfo, nil)
            }
        }

        // re-sync purchaserInfo in background in any case
        shared.apiManager.getPurchaserInfo(id: shared.profileId) { purchaserInfo, error in
            if let purchaserInfo = purchaserInfo {
                shared.purchaserInfo = purchaserInfo
            }

            // call callback in case of missing cached data
            if forceUpdate || cachedPurchaserInfo == nil {
                completion(purchaserInfo, error)
            }
        }
    }

    @objc public static func setFallbackPaywalls(_ paywalls: String, completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")

        shared.iapManager.setFallbackPaywalls(paywalls, completion: completion)
    }

    @objc public static func logShowPaywall(_ paywall: PaywallModel, completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")

        shared.kinesisManager.trackEvent(.paywallShowed, params: ["variation_id": paywall.variationId], completion: completion)
    }

    @objc public static func logShowOnboarding(name: String?, screenName: String?, screenOrder: Int, completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")
        var params = [String: String]()
        if let name = name { params["onboarding_name"] = name }
        if let screenName = screenName { params["onboarding_name"] = screenName }
        params["onboarding_screen_order"] = "\(screenOrder)"

        shared.kinesisManager.trackEvent(.onboardingScreenShowed, params: params, completion: completion)
    }

    @objc public static func setExternalAnalyticsEnabled(_ enabled: Bool, completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")

        DefaultsManager.shared.externalAnalyticsDisabled = !enabled

        let params = Parameters.formatData(with: "",
                                           type: .profileAnalytics,
                                           attributes: ["enabled": enabled])

        shared.apiManager.enableAnalytics(id: shared.profileId, params: params) { error in
            if error == nil {
                if enabled {
                    shared.syncInstallation()
                }
            }

            completion?(error)
        }
    }

    @objc public static func setVariationId(_ variationId: String, forTransactionId transactionId: String, completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")

        let attributes: Parameters = ["profile_id": shared.profileId, "variation_id": variationId, "transaction_id": transactionId]
        let params = Parameters.formatData(with: "", type: .transactionVariationId, attributes: attributes)

        shared.apiManager.setTransactionVariationId(params: params, completion: completion)
    }

    @objc public static func presentCodeRedemptionSheet() {
        LoggerManager.logMessage("Calling now: \(#function)")

        shared.iapManager.presentCodeRedemptionSheet()
    }

    @objc public static func logout(_ completion: ErrorCompletion? = nil) {
        LoggerManager.logMessage("Calling now: \(#function)")

        shared.sessionsManager.invalidateTimers()
        shared.purchaserInfo = nil
        shared.installation = nil
        UserProperties.resetStaticUuid()
        DefaultsManager.shared.clean()

        // automatically create new profile
        shared.createProfile(nil, completion)
    }
}

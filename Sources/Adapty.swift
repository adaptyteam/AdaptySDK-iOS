//
//  Adapty.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import StoreKit

#if canImport(UIKit)
    import UIKit
#endif

extension Adapty {
    static var isActivated: Bool { shared != nil }

    static let profileIdentifierStorage: ProfileIdentifierStorage = UserDefaults.standard

    /// Use this method to initialize the Adapty SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter apiKey: You can find it in your app settings in [Adapty Dashboard](https://app.adapty.io/) *App settings* > *General*.
    /// - Parameter observerMode: A boolean value controlling [Observer mode](https://docs.adapty.io/v2.0.0/docs/observer-vs-full-mode). Turn it on if you handle purchases and subscription status yourself and use Adapty for sending subscription events and analytics
    /// - Parameter customerUserId: User identifier in your system
    /// - Parameter enableUsageLogs: You can enable "Usage Logs" collection, passing here `true`
    /// - Parameter storeKit2Usage: You can override StoreKit 2 usage policy with this value
    /// - Parameter dispatchQueue: Specify the Dispatch Queue where callbacks will be executed
    /// - Parameter completion: Result callback
    public static func activate(_ apiKey: String,
                                observerMode: Bool = false,
                                customerUserId: String? = nil,
                                enableUsageLogs: Bool = true,
                                storeKit2Usage: StoreKit2Usage = .default,
                                dispatchQueue: DispatchQueue = .main,
                                _ completion: AdaptyErrorCompletion? = nil) {
        assert(apiKey.count >= 41 && apiKey.starts(with: "public_live"), "It looks like you have passed the wrong apiKey value to the Adapty SDK.")

        let logName = "activate"
        let logParams: EventParameters = [
            "observer_mode": .value(observerMode),
            "has_customer_user_id": .value(customerUserId != nil),
        ]

        async(completion, logName: logName, logParams: logParams) { completion in
            if isActivated {
                let err = AdaptyError.activateOnceError()
                Log.warn("Adapty activate error \(err)")
                completion(err)
                return
            }

            UserDefaults.standard.clearAllDataIfDifferent(apiKey: apiKey)

            Adapty.dispatchQueue = dispatchQueue

            Configuration.setStoreKit2Usage(storeKit2Usage)
            Configuration.observerMode = observerMode

            let backend = Backend(secretKey: apiKey, baseURL: Configuration.backendBaseUrl ?? Backend.publicEnvironmentBaseUrl, withProxy: Configuration.backendProxy)

            Adapty.eventsManager = EventsManager(storage: UserDefaults.standard, backend: backend)

            shared = Adapty(profileStorage: UserDefaults.standard,
                            vendorIdsStorage: UserDefaults.standard,
                            backend: backend,
                            customerUserId: customerUserId)
            LifecycleManager.shared.initialize()
            Log.info("Adapty activated withObserverMode:\(observerMode), withCustomerUserId: \(customerUserId != nil)")
            completion(nil)
        }
    }
}

extension Adapty {
    /// Use this method for identifying user with it's user id in your system.
    ///
    /// If you don't have a user id on SDK configuration, you can set it later at any time with `.identify()` method. The most common cases are after registration/authorization when the user switches from being an anonymous user to an authenticated user.
    ///
    /// - Parameters:
    ///   - customerUserId: User identifier in your system.
    ///   - completion: Result callback.
    public static func identify(_ customerUserId: String,
                                _ completion: AdaptyErrorCompletion? = nil) {
        async(completion, logName: "identify") { manager, completion in
            manager.identify(toCustomerUserId: customerUserId, completion)
        }
    }

    /// You can logout the user anytime by calling this method.
    /// - Parameter completion: Result callback.
    public static func logout(_ completion: AdaptyErrorCompletion? = nil) {
        async(completion, logName: "logout") { manager, completion in
            manager.startLogout(completion)
        }
    }
}

extension Adapty {
    /// The main function for getting a user profile. Allows you to define the level of access, as well as other parameters.
    ///
    /// The `getProfile` method provides the most up-to-date result as it always tries to query the API. If for some reason (e.g. no internet connection), the Adapty SDK fails to retrieve information from the server, the data from cache will be returned. It is also important to note that the Adapty SDK updates AdaptyProfile cache on a regular basis, in order to keep this information as up-to-date as possible.
    ///
    /// - Parameter completion: the result containing a `AdaptyProfile` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
    public static func getProfile(_ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        async(completion, logName: "get_profile") { manager, completion in
            manager.getProfileManager { profileManager in
                guard let profileManager = try? profileManager.get() else {
                    completion(.failure(profileManager.error!))
                    return
                }
                profileManager.getProfile(completion)
            }
        }
    }

    /// You can set optional attributes such as email, phone number, etc, to the user of your app. You can then use attributes to create user [segments](https://docs.adapty.io/v2.0.0/docs/segments) or just view them in CRM.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/setting-user-attributes)
    ///
    /// - Parameter params: use `AdaptyProfileParameters.Builder` class to build this object.
    public static func updateProfile(params: AdaptyProfileParameters,
                                     _ completion: AdaptyErrorCompletion? = nil) {
        async(completion, logName: "update_profile") { manager, completion in
            if let analyticsDisabled = params.analyticsDisabled {
                manager.profileStorage.setExternalAnalyticsDisabled(analyticsDisabled)
            }
            manager.getProfileManager { profileManager in
                guard let profileManager = try? profileManager.get() else {
                    completion(profileManager.error)
                    return
                }
                profileManager.updateProfile(params: params, completion)
            }
        }
    }

    /// This method is intended to be used by cross-platform SDKs, we do not expect you to use it directly.
    public static func setVariationId(from decoder: JSONDecoder,
                                      data: Data,
                                      _ completion: AdaptyErrorCompletion? = nil) {
        struct PrivateObject: Decodable {
            let variationId: String
            let transactionId: String

            enum CodingKeys: String, CodingKey {
                case variationId = "variation_id"
                case transactionId = "transaction_id"
            }
        }
        let object: PrivateObject
        do {
            object = try decoder.decode(PrivateObject.self, from: data)
        } catch {
            completion?(.decodingSetVariationIdParams(error))
            return
        }

        let logParams: EventParameters = [
            "variation_id": .value(object.variationId),
            "transaction_id": .value(object.transactionId),
        ]
        async(completion, logName: "set_variation_id", logParams: logParams) { manager, completion in
            manager.getProfileManager { profileManager in
                guard let profileManager = try? profileManager.get() else {
                    completion(profileManager.error)
                    return
                }
                profileManager.setVariationId(object.variationId, forTransactionId: object.transactionId, completion)
            }
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Adapty SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Adapty Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of ``AdaptyPaywall``.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 1) [SKPaymentTransaction](https://developer.apple.com/documentation/storekit/skpaymenttransaction).
    ///   - completion: A result containing an optional error.
    public static func setVariationId(_ variationId: String,
                                      forPurchasedTransaction transaction: SKPaymentTransaction,
                                      _ completion: AdaptyErrorCompletion? = nil) {
        let logParams: EventParameters = [
            "variation_id": .value(variationId),
            "transaction_id": .valueOrNil(transaction.transactionIdentifier),
        ]
        async(completion, logName: "set_variation_id_sk1", logParams: logParams) { manager, completion in
            manager.getProfileManager { profileManager in
                guard let profileManager = try? profileManager.get() else {
                    completion(profileManager.error)
                    return
                }
                profileManager.setVariationId(variationId, forPurchasedTransaction: transaction, completion)
            }
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Adapty SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Adapty Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of `AdaptyPaywall`.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 2) [Transaction](https://developer.apple.com/documentation/storekit/transaction).
    ///   - completion: A result containing an optional error.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public static func setVariationId(_ variationId: String,
                                      forPurchasedTransaction transaction: Transaction,
                                      _ completion: AdaptyErrorCompletion? = nil) {
        let logParams: EventParameters = [
            "variation_id": .value(variationId),
            "transaction_id": .value(String(transaction.id)),
        ]
        async(completion, logName: "set_variation_id_sk2", logParams: logParams) { manager, completion in
            manager.getProfileManager { profileManager in
                guard let profileManager = try? profileManager.get() else {
                    completion(profileManager.error)
                    return
                }
                profileManager.setVariationId(variationId, forPurchasedTransaction: transaction, completion)
            }
        }
    }

    /// Adapty allows you remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without app releases.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - id: The identifier of the desired paywall. This is the value you specified when you created the paywall in the Adapty Dashboard.
    ///   - locale: The identifier of the paywall [localization](https://docs.adapty.io/docs/paywall#localizations).
    ///             This parameter is expected to be a language code composed of one or more subtags separated by the "-" character. The first subtag is for the language, the second one is for the region (The support for regions will be added later).
    ///             Example: "en" means English, "en-US" represents US English.
    ///             If the parameter is omitted, the paywall will be returned in the default locale.
    ///   - completion: A result containing the ``AdaptyPaywall`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    public static func getPaywall(_ id: String,
                                  locale: String? = nil,
                                  _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>) {
        let logParams: EventParameters = [
            "paywall_id": .value(id),
            "locale": .valueOrNil(locale),
        ]
        async(completion, logName: "get_paywall", logParams: logParams) { manager, completion in
            let fallback = Adapty.Configuration.fallbackPaywalls?.paywalls[id]
            manager.getProfileManager(waitCreatingProfile: fallback == nil) { result in
                switch result {
                case let .success(profileManager):
                    profileManager.getPaywall(id, locale, completion)
                case let .failure(error):
                    guard error.isProfileCreateFailed, let paywall = fallback else {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(paywall))
                }
            }
        }
    }

    /// Once you have a ``AdaptyPaywall``, fetch corresponding products array using this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - paywall: the ``AdaptyPaywall`` for which you want to get a products
    ///   - completion: A result containing the ``AdaptyPaywallProduct`` objects array. The order will be the same as in the paywalls object. You can present them in your UI
    public static func getPaywallProducts(paywall: AdaptyPaywall,
                                          _ completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProduct]>) {
        async(completion, logName: "get_paywall_products", logParams: ["paywall_id": .value(paywall.id)]) { manager, completion in
            manager.skProductsManager.fetchSK1ProductsInSameOrder(productIdentifiers: paywall.vendorProductIds, fetchPolicy: .returnCacheDataElseLoad) { (result: AdaptyResult<[SKProduct]>) in
                completion(result.map { skProducts in
                    skProducts.compactMap { AdaptyPaywallProduct(paywall: paywall, skProduct: $0) }
                })
            }
        }
    }

    /// This method is intended to be used by cross-platform SDKs, we do not expect you to use it directly.
    public static func getPaywallProduct(from decoder: JSONDecoder,
                                         data: Data,
                                         _ completion: @escaping AdaptyResultCompletion<AdaptyPaywallProduct>) {
        async(completion) { manager, completion in
            let object: AdaptyPaywallProduct.PrivateObject
            do {
                object = try decoder.decode(AdaptyPaywallProduct.PrivateObject.self, from: data)
            } catch {
                completion(.failure(.decodingPaywallProduct(error)))
                return
            }

            manager.skProductsManager.fetchSK1Product(productIdentifier: object.vendorProductId, fetchPolicy: .returnCacheDataElseLoad) { result in
                completion(result.flatMap { (sk1Product: SKProduct?) -> AdaptyResult<AdaptyPaywallProduct> in
                    guard let sk1Product = sk1Product else {
                        return .failure(SKManagerError.noProductIDsFound().asAdaptyError)
                    }
                    return .success(AdaptyPaywallProduct(from: object, skProduct: sk1Product))
                })
            }
        }
    }

    /// Once you have an ``AdaptyPaywallProduct`` array, fetch introductory offers information for this products.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products#products-fetch-policy-and-intro-offer-eligibility-not-applicable-for-android)
    ///
    /// - Parameters:
    ///   - products: The ``AdaptyPaywallProduct`` array, for which information will be retrieved.
    ///   - completion: A dictionary where Key is vendorProductId and Value is corresponding ``AdaptyEligibility``.
    public static func getProductsIntroductoryOfferEligibility(products: [AdaptyPaywallProduct],
                                                               _ completion: @escaping AdaptyResultCompletion<[String: AdaptyEligibility]>) {
        async(completion,
              logName: "get_products_introductory_offer_eligibility",
              logParams: ["products": .value(products.map { $0.vendorProductId })]) { manager, completion in
            manager.skProductsManager.getIntroductoryOfferEligibility(sk1Products: products.map { $0.skProduct }) {
                completionGetIntroductoryOfferEligibility($0, manager, completion)
            }
        }
    }

    /// Once you have an ``AdaptyPaywallProduct`` array, fetch introductory offers information for this products.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products#products-fetch-policy-and-intro-offer-eligibility-not-applicable-for-android)
    ///
    /// - Parameters:
    ///   - products: The products ids `String` array, for which information will be retrieved
    ///   - completion: A dictionary where Key is vendorProductId and Value is corresponding ``AdaptyEligibility``.
    public static func getProductsIntroductoryOfferEligibility(vendorProductIds: [String],
                                                               _ completion: @escaping AdaptyResultCompletion<[String: AdaptyEligibility]>) {
        async(completion,
              logName: "get_products_introductory_offer_eligibility",
              logParams: ["products": .value(vendorProductIds)]) { manager, completion in
            manager.skProductsManager.getIntroductoryOfferEligibility(vendorProductIds: Set(vendorProductIds)) {
                completionGetIntroductoryOfferEligibility($0, manager, completion)
            }
        }
    }

    private static func completionGetIntroductoryOfferEligibility(_ result: AdaptyResult<[String: AdaptyEligibility?]>, _ manager: Adapty, _ completion: @escaping AdaptyResultCompletion<[String: AdaptyEligibility]>) {
        let introductoryOfferEligibilityByVendorProductId: [String: AdaptyEligibility?]
        switch result {
        case let .failure(error):
            completion(.failure(error))
            return
        case let .success(value):
            introductoryOfferEligibilityByVendorProductId = value
        }

        let vendorProductIdsWithUnknownEligibility = introductoryOfferEligibilityByVendorProductId.filter { $0.value == nil }.map { $0.key }

        guard !vendorProductIdsWithUnknownEligibility.isEmpty else {
            completion(.success(introductoryOfferEligibilityByVendorProductId.compactMapValues { $0 }))
            return
        }

        manager.getProfileManager { result in
            let profileManager: AdaptyProfileManager
            switch result {
            case let .failure(error):
                completion(.failure(error))
                return
            case let .success(value):
                profileManager = value
            }

            profileManager.getBackendProductStates(vendorProductIds: vendorProductIdsWithUnknownEligibility) { result in
                completion(result.map { states in
                    let states = states.asDictionary.mapValues { $0.introductoryOfferEligibility }
                    let result = introductoryOfferEligibilityByVendorProductId.merging(states, uniquingKeysWith: { _, last in last })

                    let vendorProductIdsWithUnknownEligibility = result.filter { $0.value == nil }.map { $0.key }
                    if !vendorProductIdsWithUnknownEligibility.isEmpty {
                        Log.verbose("Adapty: products without eligibility  \(vendorProductIdsWithUnknownEligibility)")
                    }

                    return result.compactMapValues { $0 }
                })
            }
        }
    }

    /// You can fetch the StoreKit receipt by calling this method
    ///
    /// If the receipt is not presented on the device, Adapty will try to refresh it by using [SKReceiptRefreshRequest](https://developer.apple.com/documentation/storekit/skreceiptrefreshrequest)
    ///
    /// - Parameters:
    ///   - completion: A result containing the receipt `Data`.
    public static func getReceipt(_ completion: @escaping AdaptyResultCompletion<Data>) {
        async(completion, logName: "get_reciept") { manager, completion in
            manager.skReceiptManager.getReceipt(refreshIfEmpty: true, completion)
        }
    }

    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``AdaptyPaywallProduct`` object retrieved from the paywall.
    ///   - completion: A result containing the ``AdaptyPurchasedInfo`` object.
    public static func makePurchase(product: AdaptyPaywallProduct,
                                    _ completion: @escaping AdaptyResultCompletion<AdaptyPurchasedInfo>) {
        let logName = "make_purchase"
        let logParams: EventParameters = [
            "paywall_name": .value(product.paywallName),
            "variation_id": .value(product.variationId),
            "product_id": .value(product.vendorProductId),
        ]

        guard SKQueueManager.canMakePayments() else {
            let stamp = Log.stamp
            Adapty.logSystemEvent(AdaptySDKMethodRequestParameters(methodName: logName, callId: stamp, params: logParams))
            let error = AdaptyError.cantMakePayments()
            Adapty.logSystemEvent(AdaptySDKMethodResponseParameters(methodName: logName, callId: stamp, error: error.description))
            completion(.failure(error))
            return
        }

        async(completion, logName: logName, logParams: logParams) { manager, completion in
            if #available(iOS 12.2, macOS 10.14.4, *), let discountId = product.promotionalOfferId {
                let profileId = manager.profileStorage.profileId

                manager.httpSession.performSignSubscriptionOfferRequest(profileId: profileId, vendorProductId: product.vendorProductId, discountId: discountId) { result in
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                    case let .success(response):

                        let payment = SKMutablePayment(product: product.skProduct)
                        payment.applicationUsername = ""
                        payment.paymentDiscount = response.discount(identifier: discountId)
                        manager.skQueueManager.makePurchase(payment: payment, product: product, completion)
                    }
                }

            } else {
                manager.skQueueManager.makePurchase(payment: SKPayment(product: product.skProduct), product: product, completion)
            }
        }
    }

    /// To restore purchases, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases#restoring-purchases)
    ///
    /// - Parameter completion: A result containing the ``AdaptyProfile`` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
    public static func restorePurchases(_ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        async(completion, logName: "restore_purchases") { manager, completion in
            manager.validateReceipt(refreshIfEmpty: true) { result in
                completion(result.map { $0.value })
            }
        }
    }
}

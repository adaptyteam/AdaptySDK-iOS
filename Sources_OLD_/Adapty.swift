//
//  Adapty.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 28.10.2019.
//

import StoreKit

#if canImport(UIKit)
    import UIKit
#endif

private let log = Log.default

extension Adapty {
    public nonisolated static var isActivated: Bool { shared != nil }

    static let profileIdentifierStorage: ProfileIdentifierStorage = UserDefaults.standard





    /// Use this method to initialize the Adapty SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter configuration: `Adapty.Configuration` which allows to configure Adapty SDK
    /// - Parameter completion: Result callback
    public nonisolated static func activate(
        with configuration: Adapty.Configuration,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        let logName = "activate"
        let logParams: EventParameters = [
            "observer_mode": configuration.observerMode,
            "has_customer_user_id": configuration.customerUserId != nil,
            "idfa_collection_disabled": configuration.idfaCollectionDisabled,
            "ip_address_collection_disabled": configuration.ipAddressCollectionDisabled,
        ]

        async(completion, logName: logName, logParams: logParams) { completion in
            if isActivated {
                let err = AdaptyError.activateOnceError()
                log.warn("Adapty activate error \(err)")
                completion(err)
                return
            }

            UserDefaults.standard.clearAllDataIfDifferent(apiKey: configuration.apiKey)

            Adapty.dispatchQueue = configuration.dispatchQueue
            Configuration.idfaCollectionDisabled = configuration.idfaCollectionDisabled
            Configuration.ipAddressCollectionDisabled = configuration.ipAddressCollectionDisabled
            Configuration.observerMode = configuration.observerMode

            let backend = Backend(with: configuration)

            Adapty.eventsManager = EventsManager(profileStorage: UserDefaults.standard, backend: backend)

            shared = Adapty(
                apiKeyPrefix: String(configuration.apiKey.prefix(while: { $0 != "." })),
                profileStorage: UserDefaults.standard,
                vendorIdsStorage: UserDefaults.standard,
                backend: backend,
                customerUserId: configuration.customerUserId
            )

            LifecycleManager.shared.initialize()

            log.info("Adapty activated withObserverMode:\(configuration.observerMode), withCustomerUserId: \(configuration.customerUserId != nil)")
            completion(nil)
        }
    }
}



extension Adapty {




    /// Once you have a ``AdaptyPaywall``, fetch corresponding products array using this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - paywall: the ``AdaptyPaywall`` for which you want to get a products
    ///   - completion: A result containing the ``AdaptyPaywallProduct`` objects array. The order will be the same as in the paywalls object. You can present them in your UI
    public s nonisolatedtatic func getPaywallProducts(
        paywall: AdaptyPaywall,
        _ completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProduct]>
    ) {
        async(completion, logName: .getPaywallProducts , logParams: ["placement_id": paywall.placementId]) { manager, completion in
            manager.skProductsManager.fetchSK1ProductsInSameOrder(productIdentifiers: paywall.vendorProductIds, fetchPolicy: .returnCacheDataElseLoad) { (result: AdaptyResult<[SK1Product]>) in
                completion(result.map { sk1Products in
                    sk1Products.compactMap { AdaptyPaywallProduct(paywall: paywall, sk1Product: $0) }
                })
            }
        }
    }

    /// This method is intended to be used by cross-platform SDKs, we do not expect you to use it directly.
    public nonisolated static func getPaywallProduct(
        from decoder: JSONDecoder,
        data: Data,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywallProduct>
    ) {
        async(completion) { manager, completion in
            let object: AdaptyPaywallProduct.PrivateObject
            do {
                object = try decoder.decode(AdaptyPaywallProduct.PrivateObject.self, from: data)
            } catch {
                completion(.failure(.decodingPaywallProduct(error)))
                return
            }

            manager.skProductsManager.fetchSK1Product(productIdentifier: object.vendorProductId, fetchPolicy: .returnCacheDataElseLoad) { result in
                completion(result.flatMap { (sk1Product: SK1Product?) -> AdaptyResult<AdaptyPaywallProduct> in
                    guard let sk1Product else {
                        return .failure(SKManagerError.noProductIDsFound().asAdaptyError)
                    }
                    return .success(AdaptyPaywallProduct(from: object, sk1Product: sk1Product))
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
    public nonisolated static func getProductsIntroductoryOfferEligibility(
        products: [AdaptyPaywallProduct],
        _ completion: @escaping AdaptyResultCompletion<[String: AdaptyEligibility]>
    ) {
        async(
            completion,
            logName: .getProductsIntroductoryOfferEligibility ,
            logParams: ["products": products.map { $0.vendorProductId }]
        ) { manager, completion in
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
    public nonisolated static func getProductsIntroductoryOfferEligibility(
        vendorProductIds: [String],
        _ completion: @escaping AdaptyResultCompletion<[String: AdaptyEligibility]>
    ) {
        async(
            completion,
            logName: .getProductsIntroductoryOfferEligibilityByStrings,
            logParams: ["products": vendorProductIds]
        ) { manager, completion in
            manager.skProductsManager.getIntroductoryOfferEligibility(vendorProductIds: Set(vendorProductIds)) {
                completionGetIntroductoryOfferEligibility($0, manager, completion)
            }
        }
    }

    private static func completionGetIntroductoryOfferEligibility(_ result: AdaptyResult<[String: AdaptyEligibility?]>, _ sdk: Adapty, _ completion: @escaping AdaptyResultCompletion<[String: AdaptyEligibility]>) {
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
            let profileManager: ProfileManager
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
                    let result = introductoryOfferEligibilityByVendorProductId.merging(states, uniquingKeysWith: { $1 })

                    let vendorProductIdsWithUnknownEligibility = result.filter { $0.value == nil }.map { $0.key }
                    if !vendorProductIdsWithUnknownEligibility.isEmpty {
                        log.verbose("Adapty: products without eligibility  \(vendorProductIdsWithUnknownEligibility)")
                    }

                    return result.compactMapValues { $0 }
                })
            }
        }
    }



    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``AdaptyPaywallProduct`` object retrieved from the paywall.
    ///   - completion: A result containing the ``AdaptyPurchasedInfo`` object.
    public nonisolated static func makePurchase(
        product: AdaptyPaywallProduct,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPurchasedInfo>
    ) {
        let logName = "make_purchase"
        let logParams: EventParameters = [
            "paywall_name": product.paywallName,
            "variation_id": product.variationId,
            "product_id": product.vendorProductId,
        ]

        guard SK1QueueManager.canMakePayments() else {
            let stamp = Log.stamp
            Adapty.trackSystemEvent(AdaptySDKMethodRequestParameters(methodName: logName, stamp: stamp, params: logParams))
            let error = AdaptyError.cantMakePayments()
            Adapty.trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: logName, stamp: stamp, error: error.description))
            completion(.failure(error))
            return
        }

        async(completion, logName: logName, logParams: logParams) { manager, completion in
            guard let discountId = product.promotionalOfferId else {
                manager.sk1QueueManager.makePurchase(payment: SKPayment(product: product.skProduct), product: product, completion)
                return
            }

            let profileId = manager.profileStorage.profileId

            manager.httpSession.performSignSubscriptionOfferRequest(profileId: profileId, vendorProductId: product.vendorProductId, discountId: discountId) { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case let .success(response):

                    let payment = SKMutablePayment(product: product.skProduct)
                    payment.applicationUsername = ""
                    payment.paymentDiscount = response.discount(identifier: discountId)
                    manager.sk1QueueManager.makePurchase(payment: payment, product: product, completion)
                }
            }
        }
    }

 }


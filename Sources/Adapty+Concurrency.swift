//
//  Adapty+Concurrency.swift
//  AdaptySDK
//
//  Created by larryonoff on 4/26/22.
//

import StoreKit

#if canImport(_Concurrency) && compiler(>=5.5.2)
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, visionOS 1.0, *)
    extension Adapty {
        /// Use this method to initialize the Adapty SDK.
        ///
        /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
        ///
        /// - Parameter apiKey: You can find it in your app settings in [Adapty Dashboard](https://app.adapty.io/) *App settings* > *General*.
        /// - Parameter observerMode: A boolean value controlling [Observer mode](https://docs.adapty.io/v2.0.0/docs/observer-vs-full-mode). Turn it on if you handle purchases and subscription status yourself and use Adapty for sending subscription events and analytics
        /// - Parameter customerUserId: User identifier in your system
        /// - Parameter dispatchQueue: Specify the Dispatch Queue where callbacks will be executed
        public static func activate(
            _ apiKey: String,
            observerMode: Bool = false,
            customerUserId: String? = nil,
            dispatchQueue: DispatchQueue = .main
        ) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.activate(
                    apiKey,
                    observerMode: observerMode,
                    customerUserId: customerUserId,
                    dispatchQueue: dispatchQueue
                ) { error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        /// Use this method for identifying user with it's user id in your system.
        ///
        /// If you don't have a user id on SDK configuration, you can set it later at any time with `.identify()` method. The most common cases are after registration/authorization when the user switches from being an anonymous user to an authenticated user.
        ///
        /// - Parameters:
        ///   - customerUserId: User identifier in your system.
        public static func identify(_ customerUserId: String) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.identify(customerUserId) { error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        /// The main function for getting a user profile. Allows you to define the level of access, as well as other parameters.
        ///
        /// The `getProfile` method provides the most up-to-date result as it always tries to query the API. If for some reason (e.g. no internet connection), the Adapty SDK fails to retrieve information from the server, the data from cache will be returned. It is also important to note that the Adapty SDK updates AdaptyProfile cache on a regular basis, in order to keep this information as up-to-date as possible.
        public static func getProfile() async throws -> AdaptyProfile {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.getProfile { result in
                    switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(profile):
                        continuation.resume(returning: profile)
                    }
                }
            }
        }

        /// You can set optional attributes such as email, phone number, etc, to the user of your app. You can then use attributes to create user [segments](https://docs.adapty.io/v2.0.0/docs/segments) or just view them in CRM.
        ///
        /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/setting-user-attributes)
        ///
        /// - Parameter params: use `AdaptyProfileParameters.Builder` class to build this object.
        public static func updateProfile(params: AdaptyProfileParameters) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.updateProfile(params: params) { error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        /// To set attribution data for the profile, use this method.
        ///
        /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/attribution-integration)
        ///
        /// - Parameter attribution: a dictionary containing attribution (conversion) data.
        /// - Parameter source: a source of attribution. The allowed values are: `.appsflyer`, `.adjust`, `.branch`, `.custom`.
        /// - Parameter networkUserId: a string profile's identifier from the attribution service.
        public static func updateAttribution(
            _ attribution: [AnyHashable: Any],
            source: AdaptyAttributionSource,
            networkUserId: String? = nil
        ) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.updateAttribution(attribution, source: source, networkUserId: networkUserId) { error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        /// Adapty allows you remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without app releases.
        ///
        /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
        ///
        /// - Parameters:
        ///   - placementId: The identifier of the desired paywall. This is the value you specified when you created the paywall in the Adapty Dashboard.
        ///   - locale: The identifier of the paywall [localization](https://docs.adapty.io/docs/paywall#localizations).
        ///             This parameter is expected to be a language code composed of one or more subtags separated by the "-" character. The first subtag is for the language, the second one is for the region (The support for regions will be added later).
        ///             Example: "en" means English, "en-US" represents US English.
        ///             If the parameter is omitted, the paywall will be returned in the default locale.
        ///   - fetchPolicy:
        /// - Returns: The ``AdaptyPaywall`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
        /// - Throws: An ``AdaptyError`` object
        public static func getPaywall(
            placementId: String,
            locale: String? = nil,
            fetchPolicy: AdaptyPaywall.FetchPolicy = .default,
            loadTimeout: TimeInterval = .defaultLoadPaywallTimeout
        ) async throws -> AdaptyPaywall {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.getPaywall(placementId: placementId, locale: locale, fetchPolicy: fetchPolicy, loadTimeout: loadTimeout) { result in
                    switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(paywall):
                        continuation.resume(returning: paywall)
                    }
                }
            }
        }

        /// Once you have a ``AdaptyPaywall``, fetch corresponding products array using this method.
        ///
        /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
        ///
        /// - Parameters:
        ///   - paywall: the ``AdaptyPaywall`` for which you want to get a products
        /// - Returns: A result containing the ``AdaptyPaywallProduct`` objects array. The order will be the same as in the paywalls object. You can present them in your UI
        /// - Throws: An ``AdaptyError`` object
        public static func getPaywallProducts(paywall: AdaptyPaywall) async throws -> [AdaptyPaywallProduct] {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.getPaywallProducts(paywall: paywall) { result in
                    switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(sk1Products):
                        continuation.resume(returning: sk1Products)
                    }
                }
            }
        }

        /// Once you have an ``AdaptyPaywallProduct`` array, fetch introductory offers information for this products.
        ///
        /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products#products-fetch-policy-and-intro-offer-eligibility-not-applicable-for-android)
        ///
        /// - Parameters:
        ///   - products: the ``AdaptyPaywallProduct`` array, for which information will be retrieved
        ///
        ///  - Returns: A dictionary where Key is vendorProductId and Value is corresponding ``AdaptyEligibility``.
        ///  - Throws: An ``AdaptyError`` object.
        public static func getProductsIntroductoryOfferEligibility(products: [AdaptyPaywallProduct]) async throws -> [String: AdaptyEligibility] {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.getProductsIntroductoryOfferEligibility(products: products) { result in
                    switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(eligibilities):
                        continuation.resume(returning: eligibilities)
                    }
                }
            }
        }

        /// Once you have an ``AdaptyPaywallProduct`` array, fetch introductory offers information for this products.
        ///
        /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products#products-fetch-policy-and-intro-offer-eligibility-not-applicable-for-android)
        ///
        /// - Parameters:
        ///   - vendorProductIds: The products ids `String` array, for which information will be retrieved
        ///  - Returns: A dictionary where Key is vendorProductId and Value is corresponding ``AdaptyEligibility``.
        ///  - Throws: An ``AdaptyError`` object.
        public static func getProductsIntroductoryOfferEligibility(vendorProductIds: [String]) async throws -> [String: AdaptyEligibility] {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.getProductsIntroductoryOfferEligibility(vendorProductIds: vendorProductIds) { result in
                    switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(eligibilities):
                        continuation.resume(returning: eligibilities)
                    }
                }
            }
        }

        /// You can fetch the StoreKit receipt by calling this method
        ///
        /// If the receipt is not presented on the device, Adapty will try to refresh it by using [SKReceiptRefreshRequest](https://developer.apple.com/documentation/storekit/skreceiptrefreshrequest)
        ///
        /// - Returns: The receipt `Data`.
        /// - Throws: An ``AdaptyError`` object.
        public static func getReceipt() async throws -> Data {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.getReceipt { result in
                    switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(response):
                        continuation.resume(returning: response)
                    }
                }
            }
        }

        /// To make the purchase, you have to call this method.
        ///
        /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
        ///
        /// - Parameters:
        ///   - product: a ``AdaptyPaywallProduct`` object retrieved from the paywall.
        /// - Returns: The ``AdaptyPurchasedInfo`` object.
        /// - Throws: An ``AdaptyError`` object
        public static func makePurchase(product: AdaptyPaywallProduct) async throws -> AdaptyPurchasedInfo {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.makePurchase(product: product) { result in
                    switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(response):
                        continuation.resume(returning: response)
                    }
                }
            }
        }

        /// To restore purchases, you have to call this method.
        ///
        /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases#restoring-purchases)
        ///
        /// - Returns: The ``AdaptyProfile`` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
        /// - Throws: An ``AdaptyError`` object
        public static func restorePurchases() async throws -> AdaptyProfile {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.restorePurchases { result in
                    switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(response):
                        continuation.resume(returning: response)
                    }
                }
            }
        }

        /// To set fallback paywalls, use this method. You should pass exactly the same payload you're getting from Adapty backend. You can copy it from Adapty Dashboard.
        ///
        /// Adapty allows you to provide fallback paywalls that will be used when a user opens the app for the first time and there's no internet connection. Or in the rare case when Adapty backend is down and there's no cache on the device.
        ///
        /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#fallback-paywalls)
        ///
        /// - Parameters:
        ///   - paywalls: a JSON representation of your paywalls/products list in the exact same format as provided by Adapty backend.
        /// - Throws: An ``AdaptyError`` object
        public static func setFallbackPaywalls(_ paywalls: Data) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.setFallbackPaywalls(paywalls) { error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        /// Call this method to notify Adapty SDK, that particular paywall was shown to user.
        ///
        /// Adapty helps you to measure the performance of the paywalls. We automatically collect all the metrics related to purchases except for paywall views. This is because only you know when the paywall was shown to a customer.
        /// Whenever you show a paywall to your user, call .logShowPaywall(paywall) to log the event, and it will be accumulated in the paywall metrics.
        ///
        /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#paywall-analytics)
        ///
        /// - Parameters:
        ///   - paywall: A ``AdaptyPaywall`` object.
        ///  - Throws: An ``AdaptyError`` object
        public static func logShowPaywall(_ paywall: AdaptyPaywall) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.logShowPaywall(paywall) { error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        /// Call this method to keep track of the user's steps while onboarding
        ///
        /// The onboarding stage is a very common situation in modern mobile apps. The quality of its implementation, content, and number of steps can have a rather significant influence on further user behavior, especially on his desire to become a subscriber or simply make some purchases.
        ///
        /// In order for you to be able to analyze user behavior at this critical stage without leaving Adapty, we have implemented the ability to send dedicated events every time a user visits yet another onboarding screen.
        ///
        /// - Parameters:
        ///   - name: Name of your onboarding.
        ///   - screenName: Readable name of a particular screen as part of onboarding.
        ///   - screenOrder: An unsigned integer value representing the order of this screen in your onboarding sequence (it must me greater than 0).
        /// - Throws: An ``AdaptyError`` object
        public static func logShowOnboarding(name: String?, screenName: String?, screenOrder: UInt) async throws {
            let params = AdaptyOnboardingScreenParameters(
                name: name,
                screenName: screenName,
                screenOrder: screenOrder
            )

            return try await withCheckedThrowingContinuation { continuation in
                Adapty.logShowOnboarding(params) { error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
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
        /// - Throws: An ``AdaptyError`` object
        public static func setVariationId(
            _ variationId: String,
            forPurchasedTransaction transaction: SKPaymentTransaction
        ) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.setVariationId(variationId, forPurchasedTransaction: transaction) { error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
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
        /// - Throws: An ``AdaptyError`` object
        @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
        public static func setVariationId(
            _ variationId: String,
            forPurchasedTransaction transaction: Transaction
        ) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.setVariationId(variationId, forPurchasedTransaction: transaction) { error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        /// You can logout the user anytime by calling this method.
        /// - Parameter completion: Result callback.
        public static func logout() async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.logout { error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }
    }
#endif

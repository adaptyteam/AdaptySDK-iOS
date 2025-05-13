//
//  Adapty+Completion.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.09.2024
//

import StoreKit

public typealias AdaptyResult<Success> = Swift.Result<Success, AdaptyError>

public typealias AdaptyErrorCompletion = @Sendable (AdaptyError?) -> Void
public typealias AdaptyResultCompletion<Success> = @Sendable (AdaptyResult<Success>) -> Void

public extension Result where Failure == AdaptyError {
    var error: AdaptyError? {
        switch self {
        case let .failure(error): error
        default: nil
        }
    }
}

package extension AdaptyConfiguration {
    @AdaptyActor
    static var callbackDispatchQueue: DispatchQueue?
}

public extension Adapty {
    /// Use this method to initialize the Adapty SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter apiKey: You can find it in your app settings in [Adapty Dashboard](https://app.adapty.io/) *App settings* > *General*.
    /// - Parameter observerMode: A boolean value controlling [Observer mode](https://docs.adapty.io/docs/observer-vs-full-mode). Turn it on if you handle purchases and subscription status yourself and use Adapty for sending subscription events and analytics
    /// - Parameter customerUserId: User identifier in your system
    /// - Parameter dispatchQueue: Specify the Dispatch Queue where callbacks will be executed
    /// - Parameter completion: Result callback
    nonisolated static func activate(
        _ apiKey: String,
        observerMode: Bool = false,
        customerUserId: String? = nil,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await activate(apiKey, observerMode: observerMode, customerUserId: customerUserId)
        }
    }

    /// Use this method to initialize the Adapty SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter configuration: `AdaptyConfiguration` which allows to configure Adapty SDK
    /// - Parameter completion: Result callback
    nonisolated static func activate(
        with configuration: AdaptyConfiguration,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await activate(with: configuration)
        }
    }

    /// Use this method for identifying user with it's user id in your system.
    ///
    /// If you don't have a user id on SDK configuration, you can set it later at any time with `.identify()` method. The most common cases are after registration/authorization when the user switches from being an anonymous user to an authenticated user.
    ///
    /// - Parameters:
    ///   - customerUserId: User identifier in your system.
    ///   - completion: Result callback.
    nonisolated static func identify(
        _ customerUserId: String,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await identify(customerUserId)
        }
    }

    /// You can logout the user anytime by calling this method.
    /// - Parameter completion: Result callback.
    nonisolated static func logout(
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await logout()
        }
    }

    /// The main function for getting a user profile. Allows you to define the level of access, as well as other parameters.
    ///
    /// The `getProfile` method provides the most up-to-date result as it always tries to query the API. If for some reason (e.g. no internet connection), the Adapty SDK fails to retrieve information from the server, the data from cache will be returned. It is also important to note that the Adapty SDK updates AdaptyProfile cache on a regular basis, in order to keep this information as up-to-date as possible.
    ///
    /// - Parameter completion: the result containing a `AdaptyProfile` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
    nonisolated static func getProfile(
        _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>
    ) {
        withCompletion(completion) {
            try await getProfile()
        }
    }

    /// You can set optional attributes such as email, phone number, etc, to the user of your app. You can then use attributes to create user [segments](https://docs.adapty.io/v2.0.0/docs/segments) or just view them in CRM.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/setting-user-attributes)
    ///
    /// - Parameter params: use `AdaptyProfileParameters.Builder` class to build this object.
    nonisolated static func updateProfile(
        params: AdaptyProfileParameters,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await updateProfile(params: params)
        }
    }

    /// To set attribution data for the profile, use this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/attribution-integration)
    ///
    /// - Parameter attribution: a dictionary containing attribution (conversion) data.
    /// - Parameter source: a source of attribution.
    /// - Parameter completion: A result containing an optional error.
    nonisolated static func updateAttribution(
        _ attribution: [AnyHashable: Any],
        source: String,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        let attributionJson: String
        do {
            let data = try JSONSerialization.data(withJSONObject: attribution)
            attributionJson = String(decoding: data, as: UTF8.self)
        } catch {
            completion?(AdaptyError.wrongAttributeData(error))
            return
        }

        withCompletion(completion) {
            try await updateAttribution(attributionJson, source: source)
        }
    }

    nonisolated static func setIntegrationIdentifier(
        key: String,
        value: String,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await setIntegrationIdentifier(key: key, value: value)
        }
    }

    /// Adapty allows you remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without app releases.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - placementId: The identifier of the desired placement. This is the value you specified when you created the placement in the Adapty Dashboard.
    ///   - locale: The identifier of the paywall [localization](https://docs.adapty.io/docs/paywall#localizations).
    ///             This parameter is expected to be a language code composed of one or more subtags separated by the "-" character. The first subtag is for the language, the second one is for the region (The support for regions will be added later).
    ///             Example: "en" means English, "en-US" represents US English.
    ///             If the parameter is omitted, the paywall will be returned in the default locale.
    ///   - fetchPolicy:by default SDK will try to load data from server and will return cached data in case of failure. Otherwise use `.returnCacheDataElseLoad` to return cached data if it exists.
    ///   - loadTimeout: This value limits the timeout for this method. If the timeout is reached, cached data or local fallback will be returned.
    ///   - completion: A result containing the ``AdaptyPaywall`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    nonisolated static func getPaywall(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default,
        loadTimeout: TimeInterval? = nil,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        withCompletion(completion) {
            try await getPaywall(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy,
                loadTimeout: loadTimeout
            )
        }
    }

    nonisolated static func getOnboarding(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default,
        loadTimeout: TimeInterval? = nil,
        _ completion: @escaping AdaptyResultCompletion<AdaptyOnboarding>
    ) {
        withCompletion(completion) {
            try await getOnboarding(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy,
                loadTimeout: loadTimeout
            )
        }
    }

    /// This method enables you to retrieve the paywall from the Default Audience without having to wait for the Adapty SDK to send all the user information required for segmentation to the server.
    ///
    /// - Parameters:
    ///   - placementId: The identifier of the desired placement. This is the value you specified when you created the placement in the Adapty Dashboard.
    ///   - locale: The identifier of the paywall [localization](https://docs.adapty.io/docs/paywall#localizations).
    ///             This parameter is expected to be a language code composed of one or more subtags separated by the "-" character. The first subtag is for the language, the second one is for the region (The support for regions will be added later).
    ///             Example: "en" means English, "en-US" represents US English.
    ///             If the parameter is omitted, the paywall will be returned in the default locale.
    ///   - fetchPolicy:by default SDK will try to load data from server and will return cached data in case of failure. Otherwise use `.returnCacheDataElseLoad` to return cached data if it exists.
    ///   - completion: A result containing the ``AdaptyPaywall`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    nonisolated static func getPaywallForDefaultAudience(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
    ) {
        withCompletion(completion) {
            try await getPaywallForDefaultAudience(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy
            )
        }
    }

    nonisolated static func getOnboardingForDefaultAudience(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default,
        _ completion: @escaping AdaptyResultCompletion<AdaptyOnboarding>
    ) {
        withCompletion(completion) {
            try await getOnboardingForDefaultAudience(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy
            )
        }
    }

    /// To set fallback paywalls, use this method. You should pass exactly the same payload you're getting from Adapty backend. You can copy it from Adapty Dashboard.
    ///
    /// Adapty allows you to provide fallback paywalls that will be used when a user opens the app for the first time and there's no internet connection. Or in the rare case when Adapty backend is down and there's no cache on the device.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#fallback-paywalls)
    ///
    /// - Parameters:
    ///   - fileURL:
    ///   - completion: Result callback.
    nonisolated static func setFallback(
        fileURL url: URL,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await setFallback(fileURL: url)
        }
    }

    /// Once you have a ``AdaptyPaywall``, fetch corresponding products array using this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - paywall: the ``AdaptyPaywall`` for which you want to get a products
    ///   - completion: A result containing the ``AdaptyPaywallProduct`` objects array. The order will be the same as in the paywalls object. You can present them in your UI
    nonisolated static func getPaywallProducts(
        paywall: AdaptyPaywall,
        _ completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProduct]>
    ) {
        withCompletion(completion) {
            try await getPaywallProducts(paywall: paywall)
        }
    }

    nonisolated static func getPaywallProductsWithoutDeterminingOffer(
        paywall: AdaptyPaywall,
        _ completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProductWithoutDeterminingOffer]>
    ) {
        withCompletion(completion) {
            try await getPaywallProductsWithoutDeterminingOffer(paywall: paywall)
        }
    }

    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``AdaptyPaywallProduct`` object retrieved from the paywall.
    ///   - completion: A result containing the ``AdaptyPurchaseResult`` object.
    nonisolated static func makePurchase(
        product: AdaptyPaywallProduct,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPurchaseResult>
    ) {
        withCompletion(completion) {
            try await makePurchase(product: product)
        }
    }

    nonisolated static func openWebPaywall(
        for product: AdaptyPaywallProduct,
        _ completion: AdaptyErrorCompletion?
    ) {
        withCompletion(completion) {
            try await openWebPaywall(for: product)
        }
    }

    nonisolated static func openWebPaywall(
        for paywall: AdaptyPaywall,
        _ completion: AdaptyErrorCompletion?
    ) {
        withCompletion(completion) {
            try await openWebPaywall(for: paywall)
        }
    }

    nonisolated static func createWebPaywallUrl(
        for product: AdaptyPaywallProduct,
        _ completion: @escaping AdaptyResultCompletion<URL>
    ) {
        withCompletion(completion) {
            try await createWebPaywallUrl(for: product)
        }
    }

    nonisolated static func createWebPaywallUrl(
        for paywall: AdaptyPaywall,
        _ completion: @escaping AdaptyResultCompletion<URL>
    ) {
        withCompletion(completion) {
            try await createWebPaywallUrl(for: paywall)
        }
    }

    nonisolated static func makePurchase(
        product: AdaptyDeferredProduct,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPurchaseResult>
    ) {
        withCompletion(completion) {
            try await makePurchase(product: product)
        }
    }

    /// You can fetch the StoreKit receipt by calling this method
    ///
    /// If the receipt is not presented on the device, Adapty will try to refresh it by using [SKReceiptRefreshRequest](https://developer.apple.com/documentation/storekit/skreceiptrefreshrequest)
    ///
    /// - Parameters:
    ///   - completion: A result containing the receipt `Data`.
    nonisolated static func getReceipt(
        _ completion: @escaping AdaptyResultCompletion<Data>
    ) {
        withCompletion(completion) {
            try await getReceipt()
        }
    }

    /// To restore purchases, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases#restoring-purchases)
    ///
    /// - Parameter completion: A result containing the ``AdaptyProfile`` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
    nonisolated static func restorePurchases(
        _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>
    ) {
        withCompletion(completion) {
            try await restorePurchases()
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
    @available(*, deprecated, renamed: "reportTransaction")
    nonisolated static func setVariationId(
        _ variationId: String,
        forPurchasedTransaction sk1Transaction: SKPaymentTransaction
    ) async throws {
        try await reportTransaction(sk1Transaction, withVariationId: variationId)
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
    @available(*, deprecated, renamed: "reportTransaction")
    nonisolated static func setVariationId(
        _ variationId: String,
        forPurchasedTransaction sk2Transaction: Transaction
    ) async throws {
        try await reportTransaction(sk2Transaction, withVariationId: variationId)
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Adapty SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Adapty Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of ``AdaptyPaywall``.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 1) [SKPaymentTransaction](https://developer.apple.com/documentation/storekit/skpaymenttransaction).
    ///   - completion: A result containing an optional error.
    @available(*, deprecated, renamed: "reportTransaction")
    nonisolated static func setVariationId(
        _ variationId: String,
        forPurchasedTransaction transaction: SKPaymentTransaction,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await reportTransaction(transaction, withVariationId: variationId)
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
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    @available(*, deprecated, renamed: "reportTransaction")
    nonisolated static func setVariationId(
        _ variationId: String,
        forPurchasedTransaction transaction: Transaction,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await reportTransaction(transaction, withVariationId: variationId)
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
    nonisolated static func reportTransaction(
        _ transaction: SKPaymentTransaction,
        withVariationId variationId: String? = nil,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await reportTransaction(transaction, withVariationId: variationId)
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
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    nonisolated static func reportTransaction(
        _ transaction: Transaction,
        withVariationId variationId: String? = nil,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await reportTransaction(transaction, withVariationId: variationId)
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
    ///   - paywall: A `AdaptyPaywall` object.
    ///   - completion: Result callback.
    nonisolated static func logShowPaywall(
        _ paywall: AdaptyPaywall,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await logShowPaywall(paywall)
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
    ///   - completion: Result callback.
    nonisolated static func logShowOnboarding(
        name: String?,
        screenName: String?,
        screenOrder: UInt,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await logShowOnboarding(name: name, screenName: screenName, screenOrder: screenOrder)
        }
    }

    nonisolated static func logShowOnboarding(
        _ params: AdaptyOnboardingScreenParameters,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await logShowOnboarding(params)
        }
    }

    /// Call this method to update the current user's refund data consent.
    ///
    /// Read more on the [Adapty Documentation](https://adapty.io/docs/refund-saver#obtain-user-consent)
    ///
    /// - Parameters:
    ///   - consent: `Bool` value wehter user gave the consent or not.
    ///   - completion: Result callback.
    nonisolated static func updateCollectingRefundDataConsent(
        _ consent: Bool,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await updateCollectingRefundDataConsent(consent)
        }
    }

    /// Call this method to set the refund preference individually for current user.
    ///
    /// Read more on the [Adapty Documentation](https://adapty.io/docs/refund-saver#set-refund-behavior-for-a-specific-user-in-the-dashboard)
    ///
    /// - Parameters:
    ///   - refundPreference: ``AdaptyRefundPreference`` value.
    ///   - completion: Result callback.
    nonisolated static func updateRefundPreference(
        _ refundPreference: AdaptyRefundPreference,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await updateRefundPreference(refundPreference)
        }
    }
}

private func withCompletion(
    _ completion: AdaptyErrorCompletion? = nil,
    from operation: @escaping @Sendable () async throws -> Void
) {
    guard let completion else {
        Task {
            try? await operation()
        }
        return
    }

    Task {
        do {
            try await operation()
            await (AdaptyConfiguration.callbackDispatchQueue ?? .main).async {
                completion(nil)
            }
        } catch {
            await (AdaptyConfiguration.callbackDispatchQueue ?? .main).async {
                completion(error.asAdaptyError ?? .convertToAdaptyErrorFailed(unknownError: error))
            }
        }
    }
}

private func withCompletion<T: Sendable>(
    _ completion: AdaptyResultCompletion<T>?,
    from operation: @escaping @Sendable () async throws -> T
) {
    guard let completion else {
        Task {
            _ = try? await operation()
        }
        return
    }

    Task {
        do {
            let result = try await operation()
            await (AdaptyConfiguration.callbackDispatchQueue ?? .main).async {
                completion(.success(result))
            }
        } catch {
            await (AdaptyConfiguration.callbackDispatchQueue ?? .main).async {
                completion(.failure(error.asAdaptyError ?? .convertToAdaptyErrorFailed(unknownError: error)))
            }
        }
    }
}

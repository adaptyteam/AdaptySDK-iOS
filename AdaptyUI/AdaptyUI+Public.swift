//
//  AdaptyPaywallControllerDelegate.swift
//
//
//  Created by Alexey Goncharov on 27.1.23..
//

#if canImport(UIKit)

import Adapty
import UIKit

@available(iOS 15.0, *)
public extension AdaptyUI {
    struct Configuration {
        public static let `default` = Configuration(
            mediaCacheConfiguration: .init(
                memoryStorageTotalCostLimit: 100 * 1024 * 1024, // 100MB
                memoryStorageCountLimit: .max,
                diskStorageSizeLimit: 100 * 1024 * 1024 // 100MB
            )
        )

        /// Represents the Media Cache configuration used in AdaptyUI
        let mediaCacheConfiguration: MediaCacheConfiguration

        public init(
            mediaCacheConfiguration: MediaCacheConfiguration
        ) {
            self.mediaCacheConfiguration = mediaCacheConfiguration
        }
    }
}

@available(iOS 15.0, *)
public extension AdaptyUI {
    /// This enum describes user initiated actions.
    enum Action {
        /// User pressed Close Button
        case close
        /// User pressed any button with URL
        case openURL(url: URL)
        /// User pressed any button with custom action (e.g. login)
        case custom(id: String)
    }
}

/// Implement this protocol to respond to different events happening inside the purchase screen.
@available(iOS 15.0, *)
public protocol AdaptyPaywallControllerDelegate: NSObject {
    /// If user performs an action process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - action: an ``AdaptyUI.Action`` value.
    func paywallController(
        _ controller: AdaptyPaywallController,
        didPerform action: AdaptyUI.Action
    )

    /// If product was selected for purchase (by user or by system), this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` which was selected.
    func paywallController(
        _ controller: AdaptyPaywallController,
        didSelectProduct product: AdaptyPaywallProduct
    )

    /// If user initiates the purchase process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` of the purchase.
    func paywallController(
        _ controller: AdaptyPaywallController,
        didStartPurchase product: AdaptyPaywallProduct
    )

    /// This method is invoked when a successful purchase is made.
    ///
    /// The default implementation is simply dismissing the controller:
    /// ```
    /// controller.dismiss(animated: true)
    /// ```
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - product: an ``AdaptyPaywallProduct`` of the purchase.
    ///   - purchasedInfo: an ``AdaptyPurchasedInfo`` object containing up to date information about successful purchase.
    func paywallController(
        _ controller: AdaptyPaywallController,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchasedInfo: AdaptyPurchasedInfo
    )

    /// This method is invoked when the purchase process fails.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - product: an ``AdaptyPaywallProduct`` of the purchase.
    ///   - error: an ``AdaptyError`` object representing the error.
    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailPurchase product: AdaptyPaywallProduct,
        error: AdaptyError
    )

    /// This method is invoked when user cancel the purchase manually.
    /// - Parameters
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` of the purchase.
    func paywallController(
        _ controller: AdaptyPaywallController,
        didCancelPurchase product: AdaptyPaywallProduct
    )

    /// If user initiates the restore process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    func paywallControllerDidStartRestore(_ controller: AdaptyPaywallController)

    /// This method is invoked when a successful restore is made.
    ///
    /// Check if the ``AdaptyProfile`` object contains the desired access level, and if so, the controller can be dismissed.
    /// ```
    /// controller.dismiss(animated: true)
    /// ```
    ///
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - profile: an ``AdaptyProfile`` object containing up to date information about the user.
    func paywallController(
        _ controller: AdaptyPaywallController,
        didFinishRestoreWith profile: AdaptyProfile
    )

    /// This method is invoked when the restore process fails.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailRestoreWith error: AdaptyError
    )

    /// This method will be invoked in case of errors during the screen rendering process.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailRenderingWith error: AdaptyError
    )

    /// This method is invoked in case of errors during the products loading process.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    /// - Returns: Return `true`, if you want to retry products fetching.
    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool
}

@available(iOS 15.0, *)
public protocol AdaptyObserverModeResolver {
    func observerMode(
        didInitiatePurchase product: AdaptyPaywallProduct,
        onStartPurchase: @escaping () -> Void,
        onFinishPurchase: @escaping () -> Void
    )
}

@available(iOS 15.0, *)
public extension AdaptyUI {
    private static var isActivated: Bool = false

    /// Use this method to initialize the AdaptyUI SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)` right after `Adapty.activate()`.
    ///
    /// - Parameter builder: `AdaptyUI.Configuration` which allows to configure AdaptyUI SDK
    static func activate(
        configuration: Configuration = .default,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        Adapty.underlayQueue.async {
            if AdaptyUI.isActivated {
                let err = AdaptyUIError.activateOnceError
                AdaptyUI.writeLog(level: .warn, message: "AdaptyUI activate error: \(err)")
                completion?(err)
                return
            }

            if !Adapty.isActivated {
                let err = AdaptyUIError.adaptyNotActivatedError
                AdaptyUI.writeLog(level: .error, message: "AdaptyUI activate error: \(err)")
                completion?(err)
                return
            }

            AdaptyUI.configureMediaCache(configuration.mediaCacheConfiguration)
            ImageUrlPrefetcher.shared.initialize()

            AdaptyUI.isActivated = true
            AdaptyUI.writeLog(level: .info, message: "AdaptyUI activated with \(configuration)")

            completion?(nil)
        }
    }

    /// If you are using the [Paywall Builder](https://adapty.io/docs/3.0/adapty-paywall-builder), you can use this method to get a configuration object for your paywall.
    ///
    /// - Parameters:
    ///   - forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
    ///   - loadTimeout: the `TimeInterval` value which limits the request time. Cached or Fallback result will be returned in case of timeout exceeds.
    ///   - completion: A result containing the ``AdaptyUI.ViewConfiguration>`` object. Use it with ``AdaptyUI`` library.
    static func getViewConfiguration(
        forPaywall paywall: AdaptyPaywall,
        loadTimeout: TimeInterval = 5.0,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.LocalizedViewConfiguration>
    ) {
        if !AdaptyUI.isActivated {
            let err = AdaptyUIError.adaptyNotActivatedError
            AdaptyUI.writeLog(level: .error, message: "AdaptyUI getViewConfiguration error: \(err)")
            completion(.failure(err))
            return
        }
        
        Adapty.getViewConfiguration(
            paywall: paywall,
            loadTimeout: loadTimeout,
            completion
        )
    }

    /// Right after receiving ``AdaptyUI.ViewConfiguration``, you can create the corresponding ``AdaptyPaywallController`` to present it afterwards.
    ///
    /// - Parameters:
    ///   - paywall: an ``AdaptyPaywall`` object, for which you are trying to get a controller.
    ///   - products: optional ``AdaptyPaywallProducts`` array. Pass this value in order to optimize the display time of the products on the screen. If you pass `nil`, ``AdaptyUI`` will automatically fetch the required products.
    ///   - viewConfiguration: an ``AdaptyUI.LocalizedViewConfiguration`` object containing information about the visual part of the paywall. To load it, use the ``AdaptyUI.getViewConfiguration(paywall:locale:)`` method.
    ///   - delegate: the object that implements the ``AdaptyPaywallControllerDelegate`` protocol. Use it to respond to different events happening inside the purchase screen.
    ///   - observerModeResolver: if you are going to use AdaptyUI in Observer Mode, pass the resolver function here.
    ///   - tagResolver: if you are going to use custom tags functionality, pass the resolver function here.
    /// - Returns: an ``AdaptyPaywallController`` object, representing the requested paywall screen.
    static func paywallController(
        for paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]? = nil,
        introductoryOffersEligibilities: [String: AdaptyEligibility]? = nil,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate,
        observerModeResolver: AdaptyObserverModeResolver? = nil,
        tagResolver: AdaptyTagResolver? = nil,
        timerResolver: AdaptyTimerResolver? = nil,
        showDebugOverlay: Bool = false
    ) throws -> AdaptyPaywallController {
        if !AdaptyUI.isActivated {
            let err = AdaptyUIError.adaptyNotActivatedError
            AdaptyUI.writeLog(level: .error, message: "AdaptyUI paywallController(for:) error: \(err)")
            throw err
        }
        
        return AdaptyPaywallController(
            paywall: paywall,
            products: products,
            introductoryOffersEligibilities: introductoryOffersEligibilities,
            viewConfiguration: viewConfiguration,
            delegate: delegate,
            observerModeResolver: observerModeResolver,
            tagResolver: tagResolver,
            timerResolver: timerResolver,
            showDebugOverlay: showDebugOverlay
        )
    }
}

#endif

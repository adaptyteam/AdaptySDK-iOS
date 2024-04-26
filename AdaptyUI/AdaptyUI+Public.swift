//
//  AdaptyPaywallControllerDelegate.swift
//
//
//  Created by Alexey Goncharov on 27.1.23..
//

import Adapty
import UIKit

@available(iOS 13.0, *)
extension AdaptyUI {
    // This enum describes user initiated actions.
    public enum Action {
        // User pressed Close Button
        case close
        // User pressed any button with URL
        case openURL(url: URL)
        // User pressed any button with custom action (e.g. login)
        case custom(id: String)
    }
}

/// Implement this protocol to respond to different events happening inside the purchase screen.
@available(iOS 13.0, *)
public protocol AdaptyPaywallControllerDelegate: NSObject {
    /// If user performs an action process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - action: an ``AdaptyUI.Action`` value.
    func paywallController(_ controller: AdaptyPaywallController,
                           didPerform action: AdaptyUI.Action)

    /// If product was selected for purchase (by user or by system), this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` which was selected.
    func paywallController(_ controller: AdaptyPaywallController,
                           didSelectProduct product: AdaptyPaywallProduct)

    /// If user initiates the purchase process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` of the purchase.
    func paywallController(_ controller: AdaptyPaywallController,
                           didStartPurchase product: AdaptyPaywallProduct)

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
    func paywallController(_ controller: AdaptyPaywallController,
                           didFinishPurchase product: AdaptyPaywallProduct,
                           purchasedInfo: AdaptyPurchasedInfo)

    /// This method is invoked when the purchase process fails.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - product: an ``AdaptyPaywallProduct`` of the purchase.
    ///   - error: an ``AdaptyError`` object representing the error.
    func paywallController(_ controller: AdaptyPaywallController,
                           didFailPurchase product: AdaptyPaywallProduct,
                           error: AdaptyError)

    /// This method is invoked when user cancel the purchase manually.
    /// - Parameters
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` of the purchase.
    func paywallController(_ controller: AdaptyPaywallController,
                           didCancelPurchase product: AdaptyPaywallProduct)

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
    func paywallController(_ controller: AdaptyPaywallController,
                           didFinishRestoreWith profile: AdaptyProfile)

    /// This method is invoked when the restore process fails.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    func paywallController(_ controller: AdaptyPaywallController,
                           didFailRestoreWith error: AdaptyError)

    /// This method will be invoked in case of errors during the screen rendering process.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    func paywallController(_ controller: AdaptyPaywallController,
                           didFailRenderingWith error: AdaptyError)

    /// This method is invoked in case of errors during the products loading process.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    /// - Returns: Return `true`, if you want to retry products fetching.
    func paywallController(_ controller: AdaptyPaywallController,
                           didFailLoadingProductsWith error: AdaptyError) -> Bool
}

@available(iOS 13.0, *)
extension AdaptyUI {
    public static let SDKVersion = "3.0.0"

    /// If you are using the [Paywall Builder](https://docs.adapty.io/docs/paywall-builder-getting-started), you can use this method to get a configuration object for your paywall.
    ///
    /// - Parameters:
    ///   - forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
    ///   - loadTimeout: the `TimeInterval` value which limits the request time. Cached or Fallback result will be returned in case of timeout exeeds.
    ///   - completion: A result containing the ``AdaptyUI.ViewConfiguration>`` object. Use it with [AdaptyUI](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git) library.
    public static func getViewConfiguration(
        forPaywall paywall: AdaptyPaywall,
        loadTimeout: TimeInterval = 5.0,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.LocalizedViewConfiguration>
    ) {
        ImageUrlPrefetcher.shared.initialize()

        AdaptyUI.getViewConfiguration([
            "paywall": paywall,
            "ui_sdk_version": AdaptyUI.SDKVersion,
            "load_timeout": loadTimeout,
        ]) { result in
            switch result {
            case let .success(viewConfiguration):
                completion(.success(viewConfiguration))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /// Right after receiving ``AdaptyUI.ViewConfiguration``, you can create the corresponding ``AdaptyPaywallController`` to present it afterwards.
    ///
    /// - Parameters:
    ///   - paywall: an ``AdaptyPaywall`` object, for which you are trying to get a controller.
    ///   - products: optional ``AdaptyPaywallProducts`` array. Pass this value in order to optimize the display time of the products on the screen. If you pass `nil`, ``AdaptyUI`` will automatically fetch the required products.
    ///   - viewConfiguration: an ``AdaptyUI.LocalizedViewConfiguration`` object containing information about the visual part of the paywall. To load it, use the ``AdaptyUI.getViewConfiguration(paywall:locale:)`` method.
    ///   - delegate: the object that implements the ``AdaptyPaywallControllerDelegate`` protocol. Use it to respond to different events happening inside the purchase screen.
    ///   - tagResolver: if you are going to use custom tags functionality, pass the resolver function here.
    /// - Returns: an ``AdaptyPaywallController`` object, representing the requested paywall screen.
    public static func paywallController(
        for paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]? = nil,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate,
        tagResolver: AdaptyTagResolver? = nil
    ) -> AdaptyPaywallController {
        AdaptyPaywallController(
            paywall: paywall,
            products: products,
            viewConfiguration: viewConfiguration,
            delegate: delegate,
            tagResolver: tagResolver
        )
    }
}

// MARK: - PB3
@available(iOS 13.0, *)
extension AdaptyUI {
    public static func paywallController3(
        for paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]? = nil,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate,
        tagResolver: AdaptyTagResolver? = nil
    ) -> AdaptyBuilder3PaywallController {
        AdaptyBuilder3PaywallController(
            paywall: paywall,
            products: products,
            viewConfiguration: viewConfiguration,
            delegate: delegate,
            tagResolver: tagResolver
        )
    }
}

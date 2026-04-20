//
//  AdaptyFlowControllerDelegate.swift
//
//
//  Created by Alexey Goncharov on 27.1.23..
//

import Adapty
import AdaptyUIBuilder
import Foundation

/// AdaptyUI is a module intended to display paywalls created with the Paywall Builder.
/// To make full use of this functionality, you need to install an additional library, as well as make additional setups in the Adapty Dashboard.
/// You can find more information in the corresponding section of [our documentation](https://adapty.io/docs/3.0/adapty-paywall-builder).
public enum AdaptyUI {}

public extension AdaptyUI {
    struct Configuration: Sendable {
        public static let `default` = Configuration(mediaCacheConfiguration: nil)

        /// Represents the Media Cache configuration used in AdaptyUI
        let mediaCacheConfiguration: AdaptyUIBuilder.MediaCacheConfiguration?

        public init(
            mediaCacheConfiguration: AdaptyUIBuilder.MediaCacheConfiguration?
        ) {
            self.mediaCacheConfiguration = mediaCacheConfiguration
        }
    }
}

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

#if canImport(UIKit)

import UIKit

/// Implement this protocol to respond to different events happening inside the purchase screen.
@MainActor
public protocol AdaptyFlowControllerDelegate: AnyObject {
    /// This method is invoked when the paywall view was presented.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyFlowController`` within which the event occurred.
    func flowControllerDidAppear(_ controller: AdaptyFlowController)

    /// This method is invoked when the paywall view was dismissed.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyFlowController`` within which the event occurred.
    func flowControllerDidDisappear(_ controller: AdaptyFlowController)

    /// If user performs an action process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///     - action: an ``AdaptyUI.Action`` value.
    func flowController(
        _ controller: AdaptyFlowController,
        didPerform action: AdaptyUI.Action
    )

    /// If product was selected for purchase (by user or by system), this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` which was selected.
    func flowController(
        _ controller: AdaptyFlowController,
        didSelectProduct product: AdaptyPaywallProduct
    )

    /// If user initiates the purchase process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` of the purchase.
    func flowController(
        _ controller: AdaptyFlowController,
        didStartPurchase product: AdaptyPaywallProduct
    )

    /// This method is invoked when a successful purchase is made.
    ///
    /// The default implementation is simply dismissing the controller:
    /// ```
    /// controller.dismiss(animated: true)
    /// ```
    /// - Parameters:
    ///   - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///   - product: an ``AdaptyPaywallProduct`` of the purchase.
    ///   - purchaseResult: an ``AdaptyPurchaseResult`` object containing up to date information about successful purchase.
    func flowController(
        _ controller: AdaptyFlowController,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    )

    /// This method is invoked when the purchase process fails.
    /// - Parameters:
    ///   - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///   - product: an ``AdaptyPaywallProduct`` of the purchase.
    ///   - error: an ``AdaptyError`` object representing the error.
    func flowController(
        _ controller: AdaptyFlowController,
        didFailPurchase product: AdaptyPaywallProduct,
        error: AdaptyError
    )

    /// If user initiates the restore process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyFlowController`` within which the event occurred.
    func flowControllerDidStartRestore(_ controller: AdaptyFlowController)

    /// This method is invoked when a successful restore is made.
    ///
    /// Check if the ``AdaptyProfile`` object contains the desired access level, and if so, the controller can be dismissed.
    /// ```
    /// controller.dismiss(animated: true)
    /// ```
    ///
    /// - Parameters:
    ///   - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///   - profile: an ``AdaptyProfile`` object containing up to date information about the user.
    func flowController(
        _ controller: AdaptyFlowController,
        didFinishRestoreWith profile: AdaptyProfile
    )

    /// This method is invoked when the restore process fails.
    /// - Parameters:
    ///   - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    func flowController(
        _ controller: AdaptyFlowController,
        didFailRestoreWith error: AdaptyError
    )

    /// This method will be invoked in case of errors during the screen rendering process.
    /// - Parameters:
    ///   - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    func flowController(
        _ controller: AdaptyFlowController,
        didFailRenderingWith error: AdaptyUIError
    )

    /// This method is invoked in case of errors during the products loading process.
    /// - Parameters:
    ///   - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    /// - Returns: Return `true`, if you want to retry products fetching.
    func flowController(
        _ controller: AdaptyFlowController,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool

    /// This method is invoked if there was a propblem with loading a subset of paywall's products.
    /// - Parameters:
    ///   - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///   - failedIds: an array with product ids which was failed to load.
    /// - Returns: Return `true`, if you want to retry products fetching.
    func flowController(
        _ controller: AdaptyFlowController,
        didPartiallyLoadProducts failedIds: [String]
    )

    /// This method is invoked when the web payment navigation is finished.
    /// - Parameters:
    ///   - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///   - product: an ``AdaptyPaywallProduct`` of the purchase.
    ///   - error: an ``AdaptyError`` object representing the error.
    func flowController(
        _ controller: AdaptyFlowController,
        didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
        error: AdaptyError?
    )

    /// This method is invoked when a custom analytic event is fired from the flow's script.
    ///
    /// Use this to forward flow-level analytics to your own analytics provider (e.g. Amplitude, Mixpanel).
    /// Only events explicitly marked as customer-facing by the flow configuration are delivered here.
    ///
    /// - Parameters:
    ///   - controller: an ``AdaptyFlowController`` within which the event occurred.
    ///   - name: the event name (e.g. `"paywall_opened"`, `"cta_tapped"`).
    ///   - params: an arbitrary dictionary of event parameters. The contents depend on the flow configuration and may include internal keys.
    func flowController(
        _ controller: AdaptyFlowController,
        didReceiveAnalyticEvent name: String,
        params: [String: any Sendable]
    )
}

public typealias AdaptyTimerResolver = AdaptyUITimerResolver

public typealias AdaptyTagResolver = AdaptyUITagResolver

public typealias AdaptyAssetsResolver = AdaptyUIAssetsResolver

public typealias AdaptyCustomAsset = AdaptyUICustomAsset

public typealias AdaptySystemRequestsHandler = AdaptyUISystemRequestsHandler

public typealias AdaptyPermission = AdaptyUIPermission

public typealias AdaptyPermissionResult = AdaptyUIPermissionResult

#endif

public protocol AdaptyObserverModeResolver: Sendable {
    func observerMode(
        didInitiatePurchase product: AdaptyPaywallProduct,
        onStartPurchase: @MainActor @Sendable @escaping () -> Void,
        onFinishPurchase: @MainActor @Sendable @escaping () -> Void
    )

    func observerModeDidInitiateRestorePurchases(
        onStartRestore: @MainActor @Sendable @escaping () -> Void,
        onFinishRestore: @MainActor @Sendable @escaping () -> Void
    )
}

@MainActor
public extension AdaptyUI {
    internal static var isActivated: Bool = false
    internal static var isObserverModeEnabled: Bool = false

    /// Use this method to initialize the AdaptyUI SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)` right after `Adapty.activate()`.
    ///
    /// - Parameter builder: `AdaptyUI.Configuration` which allows to configure AdaptyUI SDK
    static func activate(configuration: AdaptyUI.Configuration = .default) async throws {
        let stamp = Log.stamp
        let logParams = [
            "media_cache": configuration.mediaCacheConfiguration,
        ]

        Log.ui.verbose("Calling AdaptyUI activate [\(stamp)] with params: \(logParams)")

        #if canImport(UIKit)
        let sdk: Adapty

        do {
            sdk = try await Adapty.activatedSDK
        } catch {
            let err = AdaptyUIError.adaptyNotActivated
            Log.ui.error("AdaptyUI activate [\(stamp)] encountered an error: \(error).")
            throw err
        }

        guard !AdaptyUI.isActivated else {
            let err = AdaptyUIError.activateOnce
            Log.ui.error("AdaptyUI activate [\(stamp)] encountered an error: \(err).")
            throw err
        }

        AdaptyUI.isActivated = true
        AdaptyUI.isObserverModeEnabled = await sdk.observerMode

        AdaptyUIBuilder.configureMediaCache(configuration.mediaCacheConfiguration ?? .default)
        AdaptyUIBuilder.ImageUrlPrefetcher.shared.initialize()

        Log.ui.info("AdaptyUI activated successfully. [\(stamp)]")
        #else
        let err = AdaptyUIError.platformNotSupported
        Log.ui.error("AdaptyUI activate [\(stamp)] encountered an error: \(err).")
        throw err
        #endif
    }
}

#if canImport(UIKit)

@MainActor
public extension AdaptyUI {
    /// If you are using the [Paywall Builder](https://adapty.io/docs/3.0/adapty-paywall-builder), you can use this method to get a configuration object for your paywall.
    ///
    /// - Parameters:
    ///   - forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
    ///   - loadTimeout: the `TimeInterval` value which limits the request time. Cached or Fallback result will be returned in case of timeout exeeds.
    ///   - products: optional ``AdaptyPaywallProducts`` array. Pass this value in order to optimize the display time of the products on the screen. If you pass `nil`, ``AdaptyUI`` will automatically fetch the required products.
    ///   - observerModeResolver: if you are going to use AdaptyUI in Observer Mode, pass the resolver function here.
    ///   - tagResolver: if you are going to use custom tags functionality, pass the resolver function here.
    ///   - timerResolver: if you are going to use custom timers functionality, pass the resolver function here.
    /// - Returns: an ``AdaptyPaywallConfiguration`` object.
    static func getFlowConfiguration(
        forFlow flow: AdaptyFlow,
        locale: String? = nil,
        loadTimeout: TimeInterval? = nil,
        products: [AdaptyPaywallProduct]? = nil,
        observerModeResolver: AdaptyObserverModeResolver? = nil,
        tagResolver: AdaptyUITagResolver? = nil,
        timerResolver: AdaptyTimerResolver? = nil,
        assetsResolver: AdaptyUIAssetsResolver? = nil,
        systemRequestsHandler: AdaptyUISystemRequestsHandler? = nil
    ) async throws -> FlowConfiguration {
        guard AdaptyUI.isActivated else {
            let err = AdaptyUIError.adaptyUINotActivated
            Log.ui.error("AdaptyUI getViewConfiguration error: \(err)")

            throw err
        }

        let viewConfiguration = try await Adapty.getUIConfiguration(
            flow: flow,
            locale: locale,
            loadTimeout: loadTimeout
        )

        return FlowConfiguration(
            logId: Log.stamp,
            flow: flow,
            viewConfiguration: viewConfiguration,
            products: products,
            observerModeResolver: observerModeResolver,
            tagResolver: tagResolver,
            timerResolver: timerResolver,
            assetsResolver: assetsResolver,
            systemRequestsHandler: systemRequestsHandler
        )
    }

    /// Right after receiving ``AdaptyUI.ViewConfiguration``, you can create the corresponding ``AdaptyFlowController`` to present it afterwards.
    ///
    /// - Parameters:
    ///   - viewConfiguration: an ``AdaptyUI.LocalizedViewConfiguration`` object containing information about the visual part of the paywall. To load it, use the ``AdaptyUI.getViewConfiguration(paywall:locale:)`` method.
    ///   - delegate: the object that implements the ``AdaptyFlowControllerDelegate`` protocol. Use it to respond to different events happening inside the purchase screen.
    /// - Returns: an ``AdaptyFlowController`` object, representing the requested paywall screen.
    static func flowController(
        with flowConfiguration: FlowConfiguration,
        delegate: AdaptyFlowControllerDelegate,
        showDebugOverlay: Bool = false
    ) throws -> AdaptyFlowController {
        guard AdaptyUI.isActivated else {
            let err = AdaptyUIError.adaptyUINotActivated
            Log.ui.error("AdaptyUI flowController(for:) error: \(err)")
            throw err
        }

        return AdaptyFlowController(
            paywallConfiguration: flowConfiguration,
            delegate: delegate,
            showDebugOverlay: showDebugOverlay
        )
    }
}
#endif

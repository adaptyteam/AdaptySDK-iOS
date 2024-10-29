//
//  AdaptyUI+Callbacks.swift
//
//
//  Created by Alexey Goncharov on 30.8.23..
//

import Adapty
import Foundation

#if canImport(UIKit) && canImport(_Concurrency) && compiler(>=5.5.2)

@available(iOS 15.0, *)
public extension AdaptyUI {
    /// Use this method to initialize the AdaptyUI SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)` right after `Adapty.activate()`.
    ///
    /// - Parameter builder: `AdaptyUI.Configuration` which allows to configure AdaptyUI SDK
    static func activate(
        configuration: Configuration = .default,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        withCompletion(completion) {
            try await AdaptyUI.activate(configuration: configuration)
        }
    }

    /// If you are using the [Paywall Builder](https://docs.adapty.io/docs/paywall-builder-getting-started), you can use this method to get a configuration object for your paywall.
    ///
    /// - Parameters:
    ///   - forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
    ///   - loadTimeout: the `TimeInterval` value which limits the request time. Cached or Fallback result will be returned in case of timeout exceeds.
    ///   - completion: A result containing the ``AdaptyUI.ViewConfiguration>`` object. Use it with [AdaptyUI](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git) library.
    static func getViewConfiguration(
        forPaywall paywall: AdaptyPaywall,
        loadTimeout: TimeInterval = 5.0,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.LocalizedViewConfiguration>
    ) {
        withCompletion(completion) {
            try await Adapty.getViewConfiguration(
                paywall: paywall,
                loadTimeout: loadTimeout
            )
        }
    }
}
#endif

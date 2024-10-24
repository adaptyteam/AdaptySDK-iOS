//
//  AdaptyUI+Concurency.swift
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
    static func activate(configuration: Configuration = .default) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            AdaptyUI.activate(configuration: configuration) { error in
                if let error {
                    return continuation.resume(throwing: error)
                }
                continuation.resume(
                    returning: ()
                )
            }
        }
    }

    /// If you are using the [Paywall Builder](https://adapty.io/docs/3.0/adapty-paywall-builder), you can use this method to get a configuration object for your paywall.
    ///
    /// - Parameters:
    ///   - forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
    ///   - loadTimeout: the `TimeInterval` value which limits the request time. Cached or Fallback result will be returned in case of timeout exeeds.
    /// - Returns: The ``AdaptyUI.LocalizedViewConfiguration`` object. Use it with ``AdaptyUI`` library.
    static func getViewConfiguration(forPaywall paywall: AdaptyPaywall, loadTimeout: TimeInterval = 5.0) async throws -> AdaptyUI.LocalizedViewConfiguration {
        return try await withCheckedThrowingContinuation { continuation in
            AdaptyUI.getViewConfiguration(forPaywall: paywall, loadTimeout: loadTimeout) { result in
                switch result {
                case let .failure(error):
                    continuation.resume(throwing: error)
                case let .success(paywall):
                    continuation.resume(returning: paywall)
                }
            }
        }
    }
}
#endif

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
    extension AdaptyUI {
        /// If you are using the [Paywall Builder](https://docs.adapty.io/docs/paywall-builder-getting-started), you can use this method to get a configuration object for your paywall.
        ///
        /// - Parameters:
        ///   - forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
        ///   - loadTimeout: the `TimeInterval` value which limits the request time. Cached or Fallback result will be returned in case of timeout exeeds.
        /// - Returns: The ``AdaptyUI.LocalizedViewConfiguration`` object. Use it with [AdaptyUI](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git) library.
        public static func getViewConfiguration(forPaywall paywall: AdaptyPaywall, loadTimeout: TimeInterval = 5.0) async throws -> AdaptyUI.LocalizedViewConfiguration {
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

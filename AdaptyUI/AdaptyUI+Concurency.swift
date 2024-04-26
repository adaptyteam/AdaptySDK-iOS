//
//  AdaptyUI+Concurency.swift
//
//
//  Created by Alexey Goncharov on 30.8.23..
//

import Adapty
import Foundation

#if canImport(_Concurrency) && compiler(>=5.5.2)
    @available(macOS 10.15, iOS 13.0.0, watchOS 6.0, tvOS 13.0, *)
    extension AdaptyUI {
        /// If you are using the [Paywall Builder](https://docs.adapty.io/docs/paywall-builder-getting-started), you can use this method to get a configuration object for your paywall.
        ///
        /// - Parameter forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
        /// - Returns: The ``AdaptyUI.LocalizedViewConfiguration`` object. Use it with [AdaptyUI](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git) library.
        public static func getViewConfiguration(forPaywall paywall: AdaptyPaywall, locale: String) async throws -> AdaptyUI.LocalizedViewConfiguration {
            return try await withCheckedThrowingContinuation { continuation in
                AdaptyUI.getViewConfiguration(forPaywall: paywall, locale: locale) { result in
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

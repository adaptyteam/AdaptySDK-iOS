//
//  AdaptyUI+Concurrency.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 31.01.2023
//

import Foundation

/// AdaptyUI is a module intended to display paywalls created with the Paywall Builder.
/// To make full use of this functionality, you need to install an [additional library](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git), as well as make additional setups in the Adapty Dashboard.
/// You can find more information in the corresponding section of [our documentation](https://docs.adapty.io/docs/paywall-builder-getting-started).
extension AdaptyUI {
    /// If you are using the [Paywall Builder](https://docs.adapty.io/docs/paywall-builder-getting-started), you can use this method to get a configuration object for your paywall.
    ///
    /// - Parameters:
    ///   - forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
    ///   - completion: A result containing the ``AdaptyUI.ViewConfiguration>`` object. Use it with [AdaptyUI](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git) library.
    public static func getViewConfiguration(forPaywall paywall: AdaptyPaywall,
                                            locale: String,
                                            _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>) {
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: [
                "paywall_id": paywall.id,
                "paywall_variation_id": paywall.variationId,
                "locale": locale,
                "builder_version": "2.0.0", // AdaptyUI.SDKVersion,
            ])
        } catch {
//            completion(.failure( //ERROR
//            ))
            return
        }

        AdaptyUI.getViewConfiguration(data: data, completion)
    }
}

#if canImport(_Concurrency) && compiler(>=5.5.2)
    @available(macOS 10.15, iOS 13.0.0, watchOS 6.0, tvOS 13.0, *)
    extension AdaptyUI {
        /// If you are using the [Paywall Builder](https://docs.adapty.io/docs/paywall-builder-getting-started), you can use this method to get a configuration object for your paywall.
        ///
        /// - Parameter forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
        /// - Returns: The ``AdaptyUI.ViewConfiguration>`` object. Use it with [AdaptyUI](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git) library.
        public static func getViewConfiguration(forPaywall paywall: AdaptyPaywall, locale: String) async throws -> AdaptyUI.ViewConfiguration? {
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

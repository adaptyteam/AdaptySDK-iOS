//
//  AdaptyUI+Callbacks.swift
//
//
//  Created by Alexey Goncharov on 30.8.23..
//

import Adapty
import Foundation

#if canImport(UIKit) && canImport(_Concurrency) && compiler(>=5.5.2)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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
    static func getPaywallConfiguration(
        forPaywall paywall: AdaptyPaywall,
        loadTimeout: TimeInterval = 5.0,
        products: [AdaptyPaywallProduct]? = nil,
        observerModeResolver: AdaptyObserverModeResolver? = nil,
        tagResolver: AdaptyTagResolver? = nil,
        timerResolver: AdaptyTimerResolver? = nil,
        _ completion: @escaping AdaptyResultCompletion<PaywallConfiguration>
    ) {
        withCompletion(completion) {
            try await AdaptyUI.getPaywallConfiguration(
                forPaywall: paywall,
                loadTimeout: loadTimeout,
                products: products,
                observerModeResolver: observerModeResolver,
                tagResolver: tagResolver,
                timerResolver: timerResolver
            )
        }
    }
}

private func withCompletion(
    _ completion: AdaptyErrorCompletion? = nil,
    from operation: @escaping @Sendable () async throws -> Void
) {
    Task {
        do {
            try await operation()
            await (AdaptyConfiguration.callbackDispatchQueue ?? .main).async {
                completion?(nil)
            }
        } catch {
            await (AdaptyConfiguration.callbackDispatchQueue ?? .main).async {
                completion?(error.asAdaptyError)
            }
        }
    }
}

private func withCompletion<T: Sendable>(
    _ completion: @escaping AdaptyResultCompletion<T>,
    from operation: @escaping @Sendable () async throws -> T
) {
    Task {
        do {
            let result = try await operation()
            await (AdaptyConfiguration.callbackDispatchQueue ?? .main).async {
                completion(.success(result))
            }
        } catch {
            await (AdaptyConfiguration.callbackDispatchQueue ?? .main).async {
                completion(.failure(error.asAdaptyError))
            }
        }
    }
}

#endif

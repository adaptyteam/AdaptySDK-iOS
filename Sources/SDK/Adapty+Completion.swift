//
//  Adapty+Completion.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.09.2024
//

import Foundation

public typealias AdaptyResult<Success> = Swift.Result<Success, AdaptyError>

public typealias AdaptyErrorCompletion = @Sendable (AdaptyError?) -> Void
public typealias AdaptyResultCompletion<Success> = @Sendable (AdaptyResult<Success>) -> Void

extension Result where Failure == AdaptyError {
    public var error: AdaptyError? {
        switch self {
        case let .failure(error): error
        default: nil
        }
    }
}

extension Adapty {
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
//    public static func getPaywall(
//        placementId: String,
//        locale: String? = nil,
//        fetchPolicy: AdaptyPaywall.FetchPolicy = .default,
//        loadTimeout: TimeInterval = .defaultLoadPaywallTimeout,
//        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
//    ) {
//        withCompletion(completion) {
//            try await getPaywall(
//                placementId: placementId,
//                locale: locale,
//                fetchPolicy: fetchPolicy,
//                loadTimeout: loadTimeout
//            )
//        }
//    }

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
//    public static func getPaywallForDefaultAudience(
//        placementId: String,
//        locale: String? = nil,
//        fetchPolicy: AdaptyPaywall.FetchPolicy = .default,
//        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywall>
//    ) {
//        withCompletion(completion) {
//            try await getPaywallForDefaultAudience(
//                placementId: placementId,
//                locale: locale,
//                fetchPolicy: fetchPolicy
//            )
//        }
//    }

    /// To set fallback paywalls, use this method. You should pass exactly the same payload you're getting from Adapty backend. You can copy it from Adapty Dashboard.
    ///
    /// Adapty allows you to provide fallback paywalls that will be used when a user opens the app for the first time and there's no internet connection. Or in the rare case when Adapty backend is down and there's no cache on the device.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#fallback-paywalls)
    ///
    /// - Parameters:
    ///   - fileURL:
    ///   - completion: Result callback.
    public static func setFallbackPaywalls(fileURL url: URL, _ completion: AdaptyErrorCompletion? = nil) {
        withCompletion(completion) {
            try await setFallbackPaywalls(fileURL: url)
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
    public static func logShowPaywall(_ paywall: AdaptyPaywall, _ completion: AdaptyErrorCompletion? = nil) {
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
    public static func logShowOnboarding(name: String?, screenName: String?, screenOrder: UInt, _ completion: AdaptyErrorCompletion? = nil) {
        withCompletion(completion) {
            try await logShowOnboarding(name: name, screenName: screenName, screenOrder: screenOrder)
        }
    }

    public static func logShowOnboarding(_ params: AdaptyOnboardingScreenParameters, _ completion: AdaptyErrorCompletion? = nil) {
        withCompletion(completion) {
            try await logShowOnboarding(params)
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
            completion(nil)
        } catch {
            completion(error.asAdaptyError ?? .convertToAdaptyErrorFailed(unknownError: error))
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
            try await completion(.success(operation()))
        } catch {
            completion(.failure(error.asAdaptyError ?? .convertToAdaptyErrorFailed(unknownError: error)))
        }
    }
}

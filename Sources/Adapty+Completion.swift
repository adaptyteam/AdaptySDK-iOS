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
            completion(error.asAdaptyError!)
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
            completion(.failure(error.asAdaptyError!))
        }
    }
}

//
//  Adapty+Identify.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2024
//

import Foundation

public extension Adapty {
    /// Use this method for identifying user with it's user id in your system.
    ///
    /// If you don't have a user id on SDK configuration, you can set it later at any time with `.identify()` method. The most common cases are after registration/authorization when the user switches from being an anonymous user to an authenticated user.
    ///
    /// - Parameters:
    ///   - customerUserId: User identifier in your system.
    nonisolated static func identify(_ customerUserId: String, withAppAccountToken appAccountToken: UUID? = nil) async throws(AdaptyError) {
        try await withActivatedSDK(
            methodName: .identify,
            logParams: [
                "customer_user_id": customerUserId,
                "app_account_token": appAccountToken?.uuidString
            ]
        ) { sdk throws(AdaptyError) in
            try await sdk.identify(toCustomerUserId: customerUserId, withAppAccountToken: appAccountToken)
        }
    }

    /// You can logout the user anytime by calling this method.
    nonisolated static func logout() async throws(AdaptyError) {
        try await withActivatedSDK(methodName: .logout) { sdk throws(AdaptyError) in
            try await sdk.logout()
        }
    }
}

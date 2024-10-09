//
//  Adapty+Identify.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2024
//

import Foundation

extension Adapty {
    /// Use this method for identifying user with it's user id in your system.
    ///
    /// If you don't have a user id on SDK configuration, you can set it later at any time with `.identify()` method. The most common cases are after registration/authorization when the user switches from being an anonymous user to an authenticated user.
    ///
    /// - Parameters:
    ///   - customerUserId: User identifier in your system.
    public nonisolated static func identify(_: String) async throws {
        try await withActivatedSDK(methodName: .identify) { _ in

            // TODO:
//           try await sdk.identify(toCustomerUserId: customerUserId)
        }
    }

    /// You can logout the user anytime by calling this method.
    public nonisolated static func logout() async throws {
        try await withActivatedSDK(methodName: .logout) { _ in
            // TODO:
//            try await sdk.startLogout(completion)
        }
    }
}

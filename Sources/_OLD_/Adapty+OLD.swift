//
//  Adapty+OLD.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation
import StoreKit

typealias SK1Product = SKProduct
typealias SK1Transaction = SKPaymentTransaction

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
typealias SK2Product = Product

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
typealias SK2Transaction = Transaction

public final class Adapty {
    nonisolated(unsafe) static var share: Adapty!

    let profileStorage: ProfileStorage
    let apiKeyPrefix: String
    let backend: Backend

    let httpSession: HTTPSession
    lazy var httpFallbackSession: HTTPSession = backend.fallback.createHTTPSession()
    lazy var httpConfigsSession: HTTPSession = backend.configs.createHTTPSession()

    init(
        apiKeyPrefix: String,
        profileStorage: ProfileStorage,
        backend: Backend,
        customerUserId _: String?
    ) {
        self.apiKeyPrefix = apiKeyPrefix
        self.backend = backend
        self.profileStorage = profileStorage
        httpSession = backend.createHTTPSession()
    }

    static func withSDK<T: Sendable>(
        operation: @Sendable @escaping (Adapty) async throws -> T
    ) async throws -> T {
        try await operation(share)
    }

    static func logSystemEvent(_: AdaptySystemEventParameters) {}

    enum ValidatePurchaseReason: Sendable, Hashable {
        case setVariation
        case observing
        case purchasing
    }
}

extension TimeInterval {
    public static let defaultLoadPaywallTimeout: TimeInterval = 5.0
}

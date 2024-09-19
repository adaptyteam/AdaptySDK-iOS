//
//  Adapty+OLD.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public final class Adapty {
    static let profileIdentifierStorage: ProfileIdentifierStorage = UserDefaults.standard

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

    enum ValidatePurchaseReason: Sendable, Hashable {
        case setVariation
        case observing
        case purchasing
    }
}

extension TimeInterval {
    public static let defaultLoadPaywallTimeout: TimeInterval = 5.0
}

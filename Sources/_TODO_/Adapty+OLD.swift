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

    static func sdk() throws -> Adapty {
        guard let share else {
            throw AdaptyError.notActivated()
        }
        return share
    }
    
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

    func updateASATokenIfNeed(for _: VH<AdaptyProfile>) {}
    func syncTransactions(refreshReceiptIfEmpty _: Bool) async throws -> VH<AdaptyProfile>? {
        throw AdaptyError.cantMakePayments()
    }
    
//    static func withOptioanalSDK(
//        methodName: MethodName? = nil,
//        logParams: EventParameters? = nil,
//        function: StaticString = #function,
//        operation: @Sendable @escaping (Adapty?) async throws -> Void
//    ) async throws {
//        try await operation(nil)
//    }

    static func withOptioanalSDK<T: Sendable>(
        methodName: MethodName? = nil,
        logParams: EventParameters? = nil,
        function: StaticString = #function,
        operation: @Sendable @escaping (Adapty?) async throws -> T
    ) async throws -> T {
        try await operation(nil)
    }

//    static func withActivatedSDK(
//        methodName: MethodName? = nil,
//        logParams: EventParameters? = nil,
//        function: StaticString = #function,
//        operation: @Sendable @escaping (Adapty) async throws -> Void
//    ) async throws {
//        try await operation(share)
//    }

    static func withActivatedSDK<T: Sendable>(
        methodName: MethodName? = nil,
        logParams: EventParameters? = nil,
        function: StaticString = #function,
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

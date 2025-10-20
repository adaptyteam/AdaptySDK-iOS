//
//  Adapty+SetIntegrationIdentifier.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.11.2024.
//

import Foundation

extension Adapty {
    public nonisolated static func setIntegrationIdentifier(
        key: String,
        value: String
    ) async throws(AdaptyError) {
        let key = key.trimmed
        let value = value.trimmed
        // TODO: throw error if key isEmpty

        try await setIntegrationIdentifiers([key: value])
    }

    package nonisolated static func setIntegrationIdentifiers(
        _ keyValues: [String: String]
    ) async throws(AdaptyError) {
        try await withActivatedSDK(methodName: .setIntegrationIdentifiers, logParams: keyValues) { sdk throws(AdaptyError) in
            try await sdk.setIntegrationIdentifier(
                keyValues: keyValues
            )
        }
    }

    func setIntegrationIdentifier(
        keyValues: [String: String]
    ) async throws(AdaptyError) {
        let userId = try await createdProfileManager.userId

        do {
            try await httpSession.setIntegrationIdentifier(
                userId: userId,
                keyValues: keyValues
            )
        } catch {
            throw error.asAdaptyError
        }
    }
}

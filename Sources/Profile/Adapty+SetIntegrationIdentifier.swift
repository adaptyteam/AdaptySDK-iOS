//
//  Adapty+SetIntegrationIdentifier.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.11.2024.
//

import Foundation

extension Adapty {
    public nonisolated static func setIntegrationIdentifier(
        _ identifier: AdaptyIntegrationIdentifier
    ) async throws {
        try await setIntegrationIdentifiers([identifier.key.rawValue: identifier.value])
    }

    public nonisolated static func setIntegrationIdentifier(
        key: String,
        value: String
    ) async throws {
        try await setIntegrationIdentifiers([key: value])
    }

    package nonisolated static func setIntegrationIdentifiers(
        _ keyValues: [String: String]
    ) async throws {
        let logParams: EventParameters = keyValues

        try await withActivatedSDK(methodName: .setIntegrationIdentifiers, logParams: logParams) { sdk in
            try await sdk.setIntegrationIdentifier(
                keyValues: keyValues
            )
        }
    }

    func setIntegrationIdentifier(
        keyValues: [String: String]
    ) async throws {
        let profileId = try await createdProfileManager.profileId

        do {
            try await httpSession.setIntegrationIdentifier(
                profileId: profileId,
                keyValues: keyValues
            )
        } catch {
            throw error.asAdaptyError ?? .setIntegrationIdentifierFaild(unknownError: error)
        }
    }
}

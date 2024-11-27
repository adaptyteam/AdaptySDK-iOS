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
    ) async throws {
        let logParams: EventParameters = [
            key: value,
        ]

        try await withActivatedSDK(methodName: .setIntegrationIdentifiers, logParams: logParams) { sdk in
            try await sdk.setIntegrationIdentifier(
                profileId: sdk.profileStorage.profileId,
                keyValues: [key: value]
            )
        }
    }

    package nonisolated static func setIntegrationIdentifiers(
        _ keyValues: [String: String]
    ) async throws {
        let logParams: EventParameters = keyValues

        try await withActivatedSDK(methodName: .setIntegrationIdentifiers, logParams: logParams) { sdk in
            try await sdk.setIntegrationIdentifier(
                profileId: sdk.profileStorage.profileId,
                keyValues: keyValues
            )
        }
    }

    func setIntegrationIdentifier(
        profileId: String,
        keyValues: [String: String]
    ) async throws {
        let oldResponseHash = profileManager?.profile.hash

        do {
            let response = try await httpSession.setIntegrationIdentifier(
                profileId: profileId,
                keyValues: keyValues,
                responseHash: oldResponseHash
            )

            if let profile = response.flatValue() {
                profileManager?.saveResponse(profile)
            }

        } catch {
            throw error.asAdaptyError ?? .updateAttributionFaild(unknownError: error)
        }
    }
}

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
        try await setIntegrationIdentifiers([key: value])
    }

    package nonisolated static func setIntegrationIdentifiers(
        _ keyValues: [String: String]
    ) async throws(AdaptyError) {
        let logParams: EventParameters = keyValues

        try await withActivatedSDK(methodName: .setIntegrationIdentifiers, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.setIntegrationIdentifier(
                keyValues: keyValues
            )
        }
    }

    func setIntegrationIdentifier(
        keyValues: [String: String]
    ) async throws(AdaptyError) {
        let profileId = try await createdProfileManager.profileId

        do throws(HTTPError) {
            try await httpSession.setIntegrationIdentifier(
                profileId: profileId,
                keyValues: keyValues
            )
        } catch {
            throw error.asAdaptyError
        }
    }
}

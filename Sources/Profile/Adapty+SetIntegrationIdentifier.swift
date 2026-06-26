//
//  Adapty+SetIntegrationIdentifier.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.11.2024.
//

import Foundation

extension Adapty {
    public nonisolated static func setIntegrationIdentifier(
        _ identifiers: AdaptyIntegrationIdentifier...
    ) async throws(AdaptyError) {
        try await setIntegrationIdentifiers(identifiers)
    }

    package nonisolated static func setIntegrationIdentifiers(
        _ identifiers: [AdaptyIntegrationIdentifier]
    ) async throws(AdaptyError) {
        try await withActivatedSDK(methodName: .setIntegrationIdentifiers, logParams: identifiers.asDictionary) { sdk throws(AdaptyError) in
            try await sdk.setIntegrationIdentifier(
                identifiers: identifiers
            )
        }
    }

    func setIntegrationIdentifier(
        identifiers: [AdaptyIntegrationIdentifier]
    ) async throws(AdaptyError) {
        let userId = try await createdProfileManager.userId

        do {
            try await httpSession.setIntegrationIdentifier(
                userId: userId,
                identifiers: identifiers
            )
        } catch {
            throw error.asAdaptyError
        }
    }
}

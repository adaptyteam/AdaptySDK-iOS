//
//  Adapty+UpdateExternalAttributionData.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 28.10.2019.
//

import Foundation

public extension Adapty {
    /// Updates external attribution data associated with the profile.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/attribution-integration)
    ///
    /// - Parameter attribution: Attribution data supplied by the provider.
    /// - Parameter provider: The external attribution provider.
    nonisolated static func updateExternalAttribution(
        _ attribution: [AnyHashable: Any],
        provider: AdaptyExternalAttributionProvider
    ) async throws(AdaptyError) {
        let attributionJson: String
        do {
            let data = try JSONSerialization.data(withJSONObject: attribution)
            attributionJson = String(decoding: data, as: UTF8.self)
        } catch {
            throw .wrongAttributeData(error)
        }

        try await updateExternalAttribution(
            attributionJson,
            provider: provider
        )
    }

    nonisolated static func updateExternalAttribution(
        _ attributionJson: String,
        provider: AdaptyExternalAttributionProvider
    ) async throws(AdaptyError) {
        let logParams: EventParameters = [
            "provider": provider,
        ]

        try await withActivatedSDK(methodName: .updateExternalAttributionData, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.setExternalAttributionData(
                provider: provider,
                attributionJson: attributionJson
            )
        }
    }

    private func setExternalAttributionData(
        provider: AdaptyExternalAttributionProvider,
        attributionJson: String
    ) async throws(AdaptyError) {
        let (userId, oldResponseHash) = try await { () async throws(AdaptyError) in
            let manager = try await createdProfileManager
            return (manager.userId, manager.lastResponseHash)
        }()

        do {
            let response = try await httpSession.setExternalAttributionData(
                userId: userId,
                provider: provider,
                attributionJson: attributionJson,
                responseHash: oldResponseHash
            )
            handleProfileResponse(response)
        } catch {
            throw error.asAdaptyError
        }
    }
}

//
//  Adapty+UpdateAttribution.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 28.10.2019.
//

import Foundation

public extension Adapty {
    /// To set attribution data for the profile, use this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/attribution-integration)
    ///
    /// - Parameter attribution: a dictionary containing attribution (conversion) data.
    /// - Parameter source: a source of attribution. The allowed values are: `.appsflyer`, `.adjust`, `.branch` or custom.
    nonisolated static func updateAttribution(
        _ attribution: [AnyHashable: Any],
        source: AdaptyAttributionSource
    ) async throws {
        try await updateAttribution(attribution, source: source.rawValue)
    }

    /// To set attribution data for the profile, use this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/attribution-integration)
    ///
    /// - Parameter attribution: a dictionary containing attribution (conversion) data.
    /// - Parameter source: a source of attribution. The allowed values are: `.appsflyer`, `.adjust`, `.branch`, `.custom`.
    nonisolated static func updateAttribution(
        _ attribution: [AnyHashable: Any],
        source: String
    ) async throws {
        let attributionJson: String
        do {
            let data = try JSONSerialization.data(withJSONObject: attribution)
            attributionJson = String(decoding: data, as: UTF8.self)
        } catch {
            throw AdaptyError.wrongAttributeData(error)
        }

        try await updateAttribution(
            attributionJson,
            source: source
        )
    }

    nonisolated static func updateAttribution(
        _ attributionJson: String,
        source: String
    ) async throws {
        let logParams: EventParameters = [
            "source": source,
        ]

        try await withActivatedSDK(methodName: .updateAttributionData, logParams: logParams) { sdk in
            try await sdk.setAttributionData(
                source: source,
                attributionJson: attributionJson
            )
        }
    }

    fileprivate func setAttributionData(
        source: String,
        attributionJson: String
    ) async throws {
        let (profileId, oldResponseHash) = try await {
            let manager = try await createdProfileManager
            return (manager.profileId, manager.profile.hash)
        }()

        do {
            let response = try await httpSession.setAttributionData(
                profileId: profileId,
                source: source,
                attributionJson: attributionJson,
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

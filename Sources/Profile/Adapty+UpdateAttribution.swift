//
//  Adapty+UpdateAttribution.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 28.10.2019.
//

import Foundation

extension Adapty {
    /// To set attribution data for the profile, use this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/attribution-integration)
    ///
    /// - Parameter attribution: a dictionary containing attribution (conversion) data.
    /// - Parameter source: a source of attribution. The allowed values are: `.appsflyer`, `.adjust`, `.branch`, `.custom`.
    /// - Parameter networkUserId: a string profile's identifier from the attribution service.
    public nonisolated static func updateAttribution(
        _ attribution: [String: any Sendable],
        source: AdaptyAttributionSource,
        networkUserId: String? = nil
    ) async throws {
        if source == .appsflyer {
            assert(networkUserId != nil, "`networkUserId` is required for AppsFlyer attribution, otherwise we won't be able to send specific events. You can get it by accessing `AppsFlyerLib.shared().getAppsFlyerUID()` or in a similar way according to the official SDK.")
        }
        let logParams: EventParameters = [
            "source": source.rawValue,
            "has_network_user_id": networkUserId != nil,
        ]

        try await withActivatedSDK(methodName: .updateAttribution, logParams: logParams) { sdk in
            try await sdk.updateAttribution(
                profileId: sdk.profileStorage.profileId,
                attribution,
                source: source,
                networkUserId: networkUserId
            )
        }
    }

    private func updateAttribution(
        profileId: String, _ attribution: [String: any Sendable],
        source: AdaptyAttributionSource,
        networkUserId: String?
    ) async throws {
        let oldResponseHash = profileManager?.profile.hash

        do {
            let response = try await httpSession.sendAttribution(
                profileId: profileId,
                networkUserId: networkUserId,
                source: source,
                attribution: attribution,
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

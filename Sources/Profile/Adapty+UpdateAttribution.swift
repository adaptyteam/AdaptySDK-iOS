//
//  Adapty+UpdateAttribution.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 28.10.2019.
//

import Foundation
#if canImport(AdServices)
    import AdServices
#endif

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
        let oldProfile = profileManagerOrNil?.profile

        do {
            let response = try await httpSession.performSendAttributionRequest(
                profileId: profileId,
                networkUserId: networkUserId,
                source: source,
                attribution: attribution,
                responseHash: oldProfile?.hash
            )

            if let profile = response.flatValue() {
                profileManagerOrNil?.saveResponse(profile)
            }

        } catch {
            throw error.asAdaptyError ?? .updateAttributionFaild(unknownError: error)
        }
    }

    func updateASATokenIfNeed(for profile: VH<AdaptyProfile>) {
        #if canImport(AdServices)
            guard
                #available(iOS 14.3, macOS 11.1, visionOS 1.0, *),
                profileStorage.appleSearchAdsSyncDate == nil, // check if this is an actual first sync
                let attributionToken = try? Environment.getASAToken()
            else { return }

            Task {
                let profileId = profile.value.profileId

                let response = try await httpSession.performSendASATokenRequest(
                    profileId: profileId,
                    token: attributionToken,
                    responseHash: profile.hash
                )

                if let profile = response.flatValue() {
                    profileManagerOrNil?.saveResponse(profile)
                }

                if profileStorage.profileId == profileId {
                    // mark appleSearchAds attribution data as synced
                    profileStorage.setAppleSearchAdsSyncDate()
                }
            }

        #endif
    }
}

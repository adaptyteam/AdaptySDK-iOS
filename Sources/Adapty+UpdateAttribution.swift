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
    /// - Parameter completion: A result containing an optional error.
    public static func updateAttribution(_ attribution: [AnyHashable: Any], source: AdaptyAttributionSource, networkUserId: String? = nil, _ completion: AdaptyErrorCompletion? = nil) {
        if source == .appsflyer {
            assert(networkUserId != nil, "`networkUserId` is required for AppsFlyer attribution, otherwise we won't be able to send specific events. You can get it by accessing `AppsFlyerLib.shared().getAppsFlyerUID()` or in a similar way according to the official SDK.")
        }
        let logParams: EventParameters = [
            "source": .value(source.rawValue),
            "has_network_user_id": .value(networkUserId != nil),
        ]
        async(completion, logName: "update_attribution", logParams: logParams) { manager, completion in
            manager.updateAttribution(
                profileId: manager.profileStorage.profileId,
                attribution,
                source: source,
                networkUserId: networkUserId,
                completion
            )
        }
    }

    private func updateAttribution(profileId: String, _ attribution: [AnyHashable: Any], source: AdaptyAttributionSource, networkUserId: String?, _ completion: AdaptyErrorCompletion? = nil) {
        let oldProfile = state.initialized?.profile
        httpSession.performSetAttributionRequest(
            profileId: profileId,
            networkUserId: networkUserId,
            source: source,
            attribution: attribution,
            responseHash: oldProfile?.hash
        ) { [weak self] result in

            _ = result.do { profile in
                if let profile = profile.flatValue() {
                    self?.state.initialized?.saveResponse(profile)
                }
            }

            completion?(result.error)
        }
    }

    func updateASATokenIfNeed(for profile: VH<AdaptyProfile>) {
        #if canImport(AdServices)
            guard
                #available(iOS 14.3, macOS 11.1, visionOS 1.0, *),
                profileStorage.appleSearchAdsSyncDate == nil, // check if this is an actual first sync
                let attributionToken = try? Environment.getASAToken()
            else { return }

            let profileId = profile.value.profileId
            httpSession.performASATokenRequest(
                profileId: profileId,
                token: attributionToken,
                responseHash: profile.hash
            ) { [weak self] result in

                guard let profile = try? result.get() else { return }
                if let profile = profile.flatValue() {
                    self?.state.initialized?.saveResponse(profile)
                }

                if let storage = self?.profileStorage, storage.profileId == profileId {
                    // mark appleSearchAds attribution data as synced
                    storage.setAppleSearchAdsSyncDate()
                }
            }

        #endif
    }
}

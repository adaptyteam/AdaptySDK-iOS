//
//  Adapty+UpdateAttribution.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
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
            manager.updateAttribution(profileId: manager.profileStorage.profileId,
                                      attribution,
                                      source: source,
                                      networkUserId: networkUserId,
                                      completion)
        }
    }

    private func updateAttribution(profileId: String, _ attribution: [AnyHashable: Any], source: AdaptyAttributionSource, networkUserId: String?, _ completion: AdaptyErrorCompletion? = nil) {
        httpSession.performSetAttributionRequest(profileId: profileId,
                                                 networkUserId: networkUserId,
                                                 source: source,
                                                 attribution: attribution) { [weak self] error in
            if source == .appleSearchAds, error == nil, let storage = self?.profileStorage, storage.profileId == profileId {
                // mark appleSearchAds attribution data as synced
                storage.setAppleSearchAdsSyncDate()
            }
            completion?(error)
        }
    }

    func updateAppleSearchAdsAttribution() {
        #if os(iOS)
            // check if this is an actual first sync
            guard profileStorage.appleSearchAdsSyncDate == nil else { return }
            let profileId = profileStorage.profileId

            Environment.searchAdsAttribution { [weak self] attribution, error in
                guard let self = self, let attribution = attribution, error == nil else { return }

                if let values = attribution.values.map({ $0 }).first as? [String: Any],
                   let iAdAttribution = values["iad-attribution"] as? NSString {
                    // check if the user clicked an Apple Search Ads impression up to 30 days before app download
                    guard iAdAttribution.boolValue == true else { return }
                }

                self.updateAttribution(profileId: profileId, attribution, source: .appleSearchAds, networkUserId: nil)
            }
        #endif
    }
}

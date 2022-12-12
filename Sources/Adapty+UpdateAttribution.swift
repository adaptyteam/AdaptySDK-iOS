//
//  Adapty+UpdateAttribution.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

extension Adapty {
    public static func updateAttribution(_ attribution: [AnyHashable: Any], source: AdaptyAttributionSource, networkUserId: String? = nil, _ completion: AdaptyErrorCompletion? = nil) {
        if source == .appsflyer {
            assert(networkUserId != nil, "`networkUserId` is required for AppsFlyer attribution, otherwise we won't be able to send specific events. You can get it by accessing `AppsFlyerLib.shared().getAppsFlyerUID()` or in a similar way according to the official SDK.")
        }
        async(completion) { manager, completion in
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

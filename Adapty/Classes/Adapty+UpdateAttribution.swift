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
            manager.updateAttribution(attribution, source: source, networkUserId: networkUserId, completion)
        }
    }

    private func updateAttribution(_ attribution: [AnyHashable: Any], source: AdaptyAttributionSource, networkUserId: String? = nil, _ completion: AdaptyErrorCompletion? = nil) {
        httpSession.performSetAttributionRequest(profileId: profileStorage.profileId,
                                                 networkUserId: networkUserId,
                                                 source: source,
                                                 attribution: attribution) { [weak self] error in
            if source == .appleSearchAds && error == nil {
                // mark appleSearchAds attribution data as synced
                self?.profileStorage.setAppleSearchAdsSyncDate()
            }
        }
    }

    func updateAppleSearchAdsAttribution() {
        #if os(iOS)
            Environment.searchAdsAttribution { [weak self] attribution, _ in
                // check if this is an actual first sync
                guard let self = self,
                      var attribution = attribution,
                      self.profileStorage.appleSearchAdsSyncDate == nil else { return }

                if var attribution = attribution.values.map({ $0 }).first as? [String: Any],
                   let iAdAttribution = attribution["iad-attribution"] as? NSString {
                    // check if the user clicked an Apple Search Ads impression up to 30 days before app download
                    if iAdAttribution.boolValue == true {
                        attribution["asa-attribution"] = false
                        self.updateAttribution(attribution, source: .appleSearchAds)
                    }
                } else {
                    attribution["asa-attribution"] = true
                    self.updateAttribution(attribution, source: .appleSearchAds)
                }
            }
        #endif
    }
}

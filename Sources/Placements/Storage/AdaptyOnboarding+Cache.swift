//
//  AdaptyOnboarding+Cache.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.05.2026.
//

import Foundation

extension AdaptyOnboarding {
    static func cacheKey(variationId: String) -> Cache.ItemKey {
        .init(
            profileId: nil,
            itemType: .onboarding,
            itemId: variationId
        )
    }

    static func cacheKey(placementId: String, for userId: AdaptyUserId) -> Cache.ItemKey {
        .init(
            profileId: userId.profileId,
            itemType: .onboardingVariants,
            itemId: placementId
        )
    }

    static func shouldUseNew(new: Cache.Meta, existing: Cache.Meta) -> Bool {
        let existingLocale = existing.locale ?? .defaultPlacementLocale
        let newLocale = new.locale ?? .defaultPlacementLocale
        return !existingLocale.equalLanguageCode(newLocale) || existing.dataVersion <= new.dataVersion
    }

    static func shouldUseExisting(with fetchPolicy: AdaptyPlacementFetchPolicy, locale requestLocale: AdaptyLocale?) -> @Sendable (Cache.Meta) -> Bool {
        return accept

        @Sendable func accept(_ meta: Cache.Meta) -> Bool {
            guard fetchPolicy.canReturnCache(meta) else { return false }
            let existingLocale = meta.locale ?? .defaultPlacementLocale
            let newLocale = requestLocale ?? .defaultPlacementLocale
            return existingLocale.equalLanguageCode(newLocale)
        }
    }
}

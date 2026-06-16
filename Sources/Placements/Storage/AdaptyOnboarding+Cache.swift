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
        existing.locale != new.locale || existing.dataVersion <= new.dataVersion
    }

    static func shouldUseExisting(with fetchPolicy: AdaptyPlacementFetchPolicy, locale requestLocale: AdaptyLocale?) -> @Sendable (Cache.Meta) -> Bool {
        return accept

        @Sendable func accept(_ meta: Cache.Meta) -> Bool {
            guard fetchPolicy.canReturnCache(meta) else { return false }
            guard
                let locale = meta.locale,
                !locale.equalLanguageCode(AdaptyLocale.defaultPlacementLocale)
            else { return true }

            return requestLocale?.equalLanguageCode(locale) ?? false
        }
    }
}

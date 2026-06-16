//
//  AdaptyFlow+Cache.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.05.2026.
//

import Foundation

extension AdaptyFlow {
    static func cacheKey(variationId: String) -> Cache.ItemKey {
        .init(
            profileId: nil,
            itemType: .flow,
            itemId: variationId
        )
    }

    static func cacheKey(placementId: String, for userId: AdaptyUserId) -> Cache.ItemKey {
        .init(
            profileId: userId.profileId,
            itemType: .flowVariants,
            itemId: placementId
        )
    }

    static func shouldUseNew(new: Cache.Meta, existing: Cache.Meta) -> Bool {
        existing.dataVersion <= new.dataVersion
    }

    static func shouldUseExisting(with fetchPolicy: AdaptyPlacementFetchPolicy, locale _: AdaptyLocale?) -> (@Sendable (Cache.Meta) -> Bool) {
        fetchPolicy.canReturnCache
    }
}


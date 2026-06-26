//
//  PlacementContent.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2025.
//

import Foundation

protocol PlacementContent: Sendable, Encodable, DecodableWithConfiguration where DecodingConfiguration == AdaptyPlacement.DecodingConfiguration {
    var placement: AdaptyPlacement { get }
    var id: String { get }
    var variationId: String { get }
    var name: String { get }

    static func cacheKey(variationId: String) -> Cache.ItemKey
    static func cacheKey(placementId: String, for userId: AdaptyUserId) -> Cache.ItemKey

    static func shouldUseNew(new: Cache.Meta, existing: Cache.Meta) -> Bool
    static func shouldUseExisting(with fetchPolicy: AdaptyPlacementFetchPolicy, locale: AdaptyLocale?) -> @Sendable (Cache.Meta) -> Bool
}

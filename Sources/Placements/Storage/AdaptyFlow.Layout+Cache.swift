//
//  AdaptyFlow.Layout+Cache.swift
//  Adapty
//
//  Created by Aleksei Valiano on 12.06.2026.
//

import AdaptyUIBuilder
import Foundation

extension AdaptyFlow.Layout {
    var cacheKey: Cache.ItemKey {
        .init(
            profileId: nil,
            itemType: .flowLayout,
            itemId: id
        )
    }
}


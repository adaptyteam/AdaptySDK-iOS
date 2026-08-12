//
//  AdaptyPlacementFetchPolicy+Cache.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.05.2026.
//

import Foundation

extension AdaptyPlacementFetchPolicy {
    func canReturnCache(_ meta: Cache.Meta) -> Bool {
        switch self {
        case .reloadRevalidatingCacheData: false
        case .returnCacheDataElseLoad: true
        case let .returnCacheDataIfNotExpiredElseLoad(maxAge: maxAge):
            meta.storedAt.addingTimeInterval(maxAge) > Date()
        }
    }
}

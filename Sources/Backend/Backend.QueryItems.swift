//
//  Backend.QueryItems.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

private extension Backend.Request {
    static let profileIdQueryItemName = "profile_id"
    static let offerIdQueryItemName = "offer_code"
    static let vendorProductIdQueryItemName = "product"
    static let disableServerCacheQueryItemName = "disable_cache"
}

extension [HTTPRequest.QueryItems.Element] {
    func setUserProfileId(_ userId: AdaptyUserId?) -> Self {
        var queryItems = filter { $0.name != Backend.Request.profileIdQueryItemName }

        if let userId {
            queryItems.append(URLQueryItem(name: Backend.Request.profileIdQueryItemName, value: userId.profileId))
        }
        return queryItems
    }

    func setVendorProductId(_ vendorProductId: String?) -> Self {
        var queryItems = filter { $0.name != Backend.Request.vendorProductIdQueryItemName }

        if let vendorProductId {
            queryItems.append(URLQueryItem(name: Backend.Request.vendorProductIdQueryItemName, value: vendorProductId))
        }
        return queryItems
    }

    func setOfferId(_ offerId: String?) -> Self {
        var queryItems = filter { $0.name != Backend.Request.offerIdQueryItemName }

        if let offerId {
            queryItems.append(URLQueryItem(name: Backend.Request.offerIdQueryItemName, value: offerId))
        }
        return queryItems
    }

    func setDisableServerCache(_ disableServerCache: Bool) -> Self {
        var queryItems = filter { $0.name != Backend.Request.disableServerCacheQueryItemName }

        if disableServerCache {
            queryItems.append(URLQueryItem(name: Backend.Request.disableServerCacheQueryItemName, value: UUID().uuidString))
        }
        return queryItems
    }
}

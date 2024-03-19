//
//  Backend.QueryItems.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension Backend.Request {
    fileprivate static let profileIdQueryItemName = "profile_id"
    fileprivate static let discountIdQueryItemName = "offer_code"
    fileprivate static let vendorProductIdQueryItemName = "product"
}

extension [HTTPRequest.QueryItems.Element] {
    func setBackendProfileId(_ profileId: String?) -> Self {
        var queryItems = filter { $0.name != Backend.Request.profileIdQueryItemName }

        if let profileId {
            queryItems.append(URLQueryItem(name: Backend.Request.profileIdQueryItemName, value: profileId))
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

    func setDiscountId(_ discountId: String?) -> Self {
        var queryItems = filter { $0.name != Backend.Request.discountIdQueryItemName }

        if let discountId {
            queryItems.append(URLQueryItem(name: Backend.Request.discountIdQueryItemName, value: discountId))
        }
        return queryItems
    }
}

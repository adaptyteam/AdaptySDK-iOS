//
//  StoreKit.Storefront.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.11.2025.
//

import StoreKit

extension StoreKit.Storefront {
    var asAdaptyStorefront: AdaptyStorefront {
        .init(id: id, countryCode: countryCode)
    }
}

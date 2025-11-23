//
//  StoreKit.Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

extension StoreKit.Product {
    var asAdaptyProduct: AdaptySK2Product {
        SK2ProductWrapper(skProduct: self)
    }
}


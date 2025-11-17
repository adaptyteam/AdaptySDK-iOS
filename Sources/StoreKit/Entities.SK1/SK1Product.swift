//
//  SK1Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

typealias SK1Product = SKProduct

extension SK1Product {
    @inlinable
    var unfIsFamilyShareable: Bool { isFamilyShareable }
}

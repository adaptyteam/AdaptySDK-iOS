//
//  BackendProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.08.2025.
//

import Foundation

package struct BackendProduct: Sendable {
    let adaptyId: String
    let vendorId: String
    let accessLevelId: String
    let period: Period

    package init(adaptyId: String, vendorId: String, accessLevelId: String, period: Period) {
        self.adaptyId = adaptyId
        self.vendorId = vendorId
        self.accessLevelId = accessLevelId
        self.period = period
    }
}

extension BackendProduct: Hashable {}

extension BackendProduct: CustomStringConvertible {
    package var description: String {
        "(adaptyId: \(adaptyId), vendorId: \(vendorId), accessLevelId: \(accessLevelId), period: \(period))"
    }
}

extension BackendProduct: Codable {
    enum CodingKeys: String, CodingKey {
        case vendorId = "vendor_product_id"
        case adaptyId = "adapty_product_id"
        case accessLevelId = "access_level_id"
        case period = "product_type"
    }
}

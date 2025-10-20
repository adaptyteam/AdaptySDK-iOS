//
//  BackendProductInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.08.2025.
//

import Foundation

package struct BackendProductInfo: Sendable {
    let vendorId: String
    let accessLevelId: String
    let period: Period

    package init(vendorId: String, accessLevelId: String, period: Period) {
        self.vendorId = vendorId
        self.accessLevelId = accessLevelId
        self.period = period
    }
}

extension BackendProductInfo: Hashable {}

extension BackendProductInfo: CustomStringConvertible {
    package var description: String {
        "(vendorId: \(vendorId), accessLevelId: \(accessLevelId), period: \(period))"
    }
}

extension BackendProductInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case vendorId = "vendor_product_id"
        case accessLevelId = "access_level_id"
        case period = "product_type"
    }
}

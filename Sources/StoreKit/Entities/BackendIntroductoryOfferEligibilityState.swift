//
//  BackendIntroductoryOfferEligibilityState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct BackendIntroductoryOfferEligibilityState: Sendable, Hashable {
    let vendorId: String
    var value: Bool
    let version: Int64
}

extension BackendIntroductoryOfferEligibilityState: CustomStringConvertible {
    public var description: String {
        "(vendorId: \(vendorId), value: \(value), version: \(version))"
    }
}

extension BackendIntroductoryOfferEligibilityState: Codable {
    enum CodingKeys: String, CodingKey {
        case vendorId = "vendor_product_id"
        case value = "introductory_offer_eligibility"
        case version = "timestamp"
    }
}

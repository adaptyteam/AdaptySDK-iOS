//
//  BackendProductState.json.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 22.11.2022
//

@testable import Adapty

extension BackendProductState {
    enum ValidJSON {
        static let all = [full, withEligibilityAsBool]

        static let withEligibilityAsBool: JSONValue = [
            "vendor_product_id": "weekly.premium.599",
            "introductory_offer_eligibility": true,
            "timestamp": 1666000011111,
        ]

        static let full: JSONValue = [
            "vendor_product_id": "yearly.premium.6999",
            "introductory_offer_eligibility": "eligible",
            "timestamp": 1666000000000,
        ]
    }

    enum InvalidJSON {
        static let all = [withoutVendorId, withoutVersion]

        static let withoutVendorId: JSONValue = [
            "introductory_offer_eligibility": true,
            "timestamp": 1666346230347,
        ]

        static let withoutVersion: JSONValue = [
            "vendor_product_id": "yearly.premium.6999",
            "introductory_offer_eligibility": true,
        ]
    }
}

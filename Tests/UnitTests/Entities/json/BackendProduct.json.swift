//
//  BackendProduct.json.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 22.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK

extension BackendProduct {
    enum ValidJSON {
        static let all = [full, withEligibilityAsBool, withoutTitle, withoutPromotionalOfferId]

        static let withEligibilityAsBool: JSONValue = [
            "title": "Weekly Premium",
            "vendor_product_id": "weekly.premium.599",
            "promotional_offer_id": nil,
            "introductory_offer_eligibility": true,
            "promotional_offer_eligibility": true,
            "timestamp": 1666000011111,
        ]

        static let full: JSONValue = [
            "title": "Yearly Premium",
            "vendor_product_id": "yearly.premium.6999",
            "promotional_offer_id": "promo000",
            "introductory_offer_eligibility": "eligible",
            "promotional_offer_eligibility": true,
            "timestamp": 1666000000000,
        ]

        static let withoutTitle: JSONValue = [
            "vendor_product_id": "without.title",
            "promotional_offer_id": "promo222",
            "introductory_offer_eligibility": "unknown",
            "promotional_offer_eligibility": true,
            "timestamp": 1666000022222,
        ]

        static let withoutPromotionalOfferId: JSONValue = [
            "title": "With out PromotionalOfferId",
            "vendor_product_id": "aaa.pppppp.ccccc",
            "introductory_offer_eligibility": "ineligible",
            "promotional_offer_eligibility": false,
            "timestamp": 1666000033333,
        ]
    }

    enum InvalidJSON {
        static let all = [withoutVendorId, withoutVersion]

        static let withoutVendorId: JSONValue = [
            "title": "Yearly Premium",
            "introductory_offer_eligibility": true,
            "promotional_offer_eligibility": false,
            "timestamp": 1666346230347,
        ]

        static let withoutVersion: JSONValue = [
            "title": "Yearly Premium",
            "vendor_product_id": "yearly.premium.6999",
            "introductory_offer_eligibility": true,
            "promotional_offer_eligibility": false,
        ]
    }
}

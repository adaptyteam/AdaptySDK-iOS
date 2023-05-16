//
//  AdaptyPaywall.ProductReference.json.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 16.05.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

@testable import AdaptySDK

extension AdaptyPaywall.ProductReference {
    enum ValidJSON {
        static let all = [full, withoutTitle, withoutPromotionalOfferId]

        static let full: JSONValue = [
            "title": "Yearly Premium",
            "vendor_product_id": "yearly.premium.6999",
            "promotional_offer_id": "promo000",
            "promotional_offer_eligibility": true,
        ]

        static let withoutTitle: JSONValue = [
            "vendor_product_id": "without.title",
            "promotional_offer_id": "promo222",
            "promotional_offer_eligibility": true,
        ]

        static let withoutPromotionalOfferId: JSONValue = [
            "title": "With out PromotionalOfferId",
            "vendor_product_id": "aaa.pppppp.ccccc",
            "promotional_offer_eligibility": false,
        ]
    }

    enum InvalidJSON {
        static let all = [withoutVendorId]

        static let withoutVendorId: JSONValue = [
            "title": "Yearly Premium",
            "promotional_offer_eligibility": false,
        ]
    }
}

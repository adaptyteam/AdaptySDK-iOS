//
//  AdaptyPaywall.ProductReference.json.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 16.05.2023
//

@testable import Adapty

extension AdaptyPaywall.ProductReference {
    enum ValidJSON {
        static let all = [full, withoutTitle, withoutPromotionalOfferId]

        static let full: JSONValue = [
            "title": "Yearly Premium",
            "vendor_product_id": "yearly.premium.6999",
            "adapty_product_id": "yearly.premium.6999",
            "promotional_offer_id": "promo000",
            "promotional_offer_eligibility": true,
        ]

        static let withoutTitle: JSONValue = [
            "vendor_product_id": "without.title",
            "adapty_product_id": "without.title",
            "promotional_offer_id": "promo222",
            "promotional_offer_eligibility": true,
        ]

        static let withoutPromotionalOfferId: JSONValue = [
            "title": "With out PromotionalOfferId",
            "vendor_product_id": "without.promotionalOfferId",
            "adapty_product_id": "without.promotionalOfferId",
            "promotional_offer_eligibility": false,
        ]
    }

    enum InvalidJSON {
        static let all = [withoutVendorProductId, withoutAdaptyProductId]

        static let withoutVendorProductId: JSONValue = [
            "adapty_product_id": "without.vendorProductId",
            "title": "Yearly Premium",
            "promotional_offer_eligibility": false,
        ]

        static let withoutAdaptyProductId: JSONValue = [
            "vendor_product_id": "without.adaptyProductId",
            "title": "Yearly Premium",
            "promotional_offer_eligibility": false,
        ]
    }
}

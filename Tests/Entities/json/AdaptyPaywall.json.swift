//
//  AdaptyPaywall.json.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 22.11.2022
//

@testable import Adapty

extension AdaptyPaywall {
    enum ValidJSON {
        static let all = [full, withoutRemouteConfig, productsEmpty]

        static let full: JSONValue = [
            "developer_id": "full_example",
            "paywall_id": "id-123",
            "revision": 16,
            "variation_id": "5f509ba1-c202-4a3a-afa1-06d10c8d40f2",
            "ab_test_name": "A/B Test For Example",
            "paywall_name": "Yellow Vertical",
            "paywall_updated_at": 1664642977264,
            "products": .array(AdaptyPaywall.ProductReference.ValidJSON.all),
            "is_promo": false,
            "visual_paywall": nil,
            "remote_config": ["lang": "br",
                              "data": "{\"title\":\"Meet Purple Subscription (edit 1):\",\"subtitle\":\"• benefit 1\\n• benefit 2\\n• benefit 3\",\"accent_color\":\"#781C68\",\"background_color\":\"#ebe134\"}",
            ],
        ]

        static let withoutRemouteConfig: JSONValue = [
            "developer_id": "without_remoute_config_example",
            "paywall_id": "id-123",
            "revision": 16,
            "variation_id": "5f509ba1-c202-4a3a-afa1-06d10c8d40f2",
            "ab_test_name": "A/B Test For Example",
            "paywall_name": "Yellow Vertical",
            "paywall_updated_at": 1664642977264,
            "products": .array([AdaptyPaywall.ProductReference.ValidJSON.full, AdaptyPaywall.ProductReference.ValidJSON.withoutTitle]),
            "is_promo": false,
            "visual_paywall": nil,
        ]

        static let productsEmpty: JSONValue = [
            "developer_id": "products_empty_example",
            "paywall_id": "id-123",
            "revision": 16,
            "variation_id": "5f509ba1-c202-4a3a-afa1-06d10c8d40f2",
            "ab_test_name": "A/B Test For Example",
            "paywall_name": "Yellow Vertical",
            "paywall_updated_at": 1664642977264,
            "products": .array([]),
            "is_promo": false,
            "visual_paywall": nil,
            "remote_config": ["lang": "br",
                              "data": "{\"title\":\"Meet Purple Subscription (edit 1):\",\"subtitle\":\"• benefit 1\\n• benefit 2\\n• benefit 3\",\"accent_color\":\"#781C68\",\"background_color\":\"#ebe134\"}",
            ],
        ]
    }

    enum InvalidJSON {
        static let all = [wrongProducts, withoutProducts]

        static let wrongProducts: JSONValue = [
            "developer_id": "wrong_products_example",
            "paywall_id": "id-123",
            "revision": 16,
            "variation_id": "5f509ba1-c202-4a3a-afa1-06d10c8d40f2",
            "ab_test_name": "A/B Test For Example",
            "paywall_name": "Yellow Vertical",
            "paywall_updated_at": 1664642977264,
            "products": .array(AdaptyPaywall.ProductReference.InvalidJSON.all),
            "is_promo": false,
            "visual_paywall": nil,
            "remote_config": ["lang": "br",
                              "data": "{\"title\":\"Meet Purple Subscription (edit 1):\",\"subtitle\":\"• benefit 1\\n• benefit 2\\n• benefit 3\",\"accent_color\":\"#781C68\",\"background_color\":\"#ebe134\"}",
            ],
        ]

        static let withoutProducts: JSONValue = [
            "developer_id": "without_products_example",
            "paywall_id": "id-123",
            "revision": 16,
            "variation_id": "5f509ba1-c202-4a3a-afa1-06d10c8d40f2",
            "ab_test_name": "A/B Test For Example",
            "paywall_name": "Yellow Vertical",
            "paywall_updated_at": 1664642977264,
            "is_promo": false,
            "visual_paywall": nil,
            "remote_config": ["lang": "br",
                              "data": "{\"title\":\"Meet Purple Subscription (edit 1):\",\"subtitle\":\"• benefit 1\\n• benefit 2\\n• benefit 3\",\"accent_color\":\"#781C68\",\"background_color\":\"#ebe134\"}",
            ],
        ]
    }
}

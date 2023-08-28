//
//  AdaptyUI.ViewConfiguration.json.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 19.08.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

@testable import AdaptySDK

extension AdaptyUI.ViewConfiguration {
    enum ValidJSON {
        static let all = [short, short_with_front_data]

        static let short: JSONValue = [
            "paywall_builder_id": "bla-bla-short",
            "paywall_builder_config": [
                "format": "2.0.0",
                "template_id": "14c3d623-2f3a-455a-aa86-ef83dff6913b",
                "template_revision": 145,
                "styles": .object([:]),
            ],
        ]

        static let short_with_front_data: JSONValue = [
            "paywall_builder_id": "bla-bla-short_with_front_data",
            "paywall_builder_config": [
                "format": "2.0.0",
                "template_id": "14c3d623-2f3a-455a-aa86-ef83dff6913b",
                "template_revision": 145,
                "styles": .object([:]),
                "front_data": [
                    "type": "front_data",
                    "is_show_price_period": true
                ],
            ],
        ]
    }

    enum InvalidJSON {
        static let all = [withoutFormat, withoutTemplate, withoutStyles]

        static let withoutFormat: JSONValue = [
            "paywall_builder_id": "bla-bla-without-format",
            "paywall_builder_config": [
                "template_id": "14c3d623-2f3a-455a-aa86-ef83dff6913b",
                "template_revision": 145,
                "styles": .object([:]),
            ],
        ]

        static let withoutTemplate: JSONValue = [
            "paywall_builder_id": "bla-bla-without-template",
            "paywall_builder_config": [
                "format": "2.0.0",
                "styles": .object([:]),
            ],
        ]

        static let withoutStyles: JSONValue = [
            "paywall_builder_id": "bla-bla-without-styles",
            "paywall_builder_config": [
                "format": "2.0.0",
                "template_id": "14c3d623-2f3a-455a-aa86-ef83dff6913b",
                "template_revision": 145,
            ],
        ]
    }
}

//
//  AdaptyUI.Localization.json.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 19.01.2023
//

@testable import Adapty

extension AdaptyUI.Localization {
    enum ValidJSON {
        static let all = [empty, full, example]

        static let empty: JSONValue = [
            "id": "en-GB",
            "strings": .array([]),
        ]

        static let full: JSONValue = [
            "id": "en-GB",
            "strings": .array([]),
            "assets": AdaptyUI.Assets.ValidJSON.colors,
        ]

        static let example: JSONValue = [
            "id": "en-GB",
            "strings": .array([
                [
                    "id": "str-terms-id",
                    "value": "Terms of Use",
                ],
                [
                    "id": "str-privacy-id",
                    "value": "Privacy Policy",
                ],
                [
                    "id": "str-title",
                    "value": "Unlimited Premium Access",
                ],
                [
                    "id": "str-feature-0",
                    "value": "Personal training plan",
                ],
                [
                    "id": "str-feature-1",
                    "value": "Life changing advices",
                ],
                [
                    "id": "str-feature-2",
                    "value": "Food plans",
                ],
                [
                    "id": "str-purchase-btn",
                    "value": "Continue",
                ],
                [
                    "id": "str-main-product-tag",
                    "value": "Most Popular",
                ],
                [
                    "id": "str-terms",
                    "value": "Terms",
                ],
                [
                    "id": "str-privacy",
                    "value": "Privacy",
                ],
                [
                    "id": "str-restore",
                    "value": "Restore",
                ],
                [
                    "id": "url-terms",
                    "value": "https://adapty.io/terms/en",
                ],
                [
                    "id": "url-privacy",
                    "value": "https://adapty.io/privacy/en",
                ],
            ]),
        ]
    }

    enum InvalidJSON {
        static let all = [withoutId, wrongString1, wrongString2]

        static let withoutId: JSONValue = [
            "strings": .array([]),
        ]

        static let wrongString1: JSONValue = [
            "id": "en-GB",
            "strings": .array([
                [
                    "id": "str-terms-id",
                ],
            ]),
        ]

        static let wrongString2: JSONValue = [
            "id": "en-GB",
            "strings": .array([
                [
                    "value": "Restore",
                ],
            ]),
        ]
    }
}

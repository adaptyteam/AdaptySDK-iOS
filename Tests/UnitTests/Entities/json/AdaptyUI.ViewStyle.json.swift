//
//  AdaptyUI.ViewStyle.json.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 13.07.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

@testable import AdaptySDK

extension AdaptyUI.ViewStyle {
    enum ValidJSON {
        static let all = [short, full]

        static let short: JSONValue = [
            "products_block": [
                "type": "vertical",
            ],

        ]

        static let full: JSONValue = [
            "footer_block": [:],
            "features_block": [
                "type": "list",
            ],
            "products_block": [
                "type": "single",
                "main_product_index": 0,
            ],
            "shape_example1": [
                "type": "shape",
            ],
            "shape_example2": [
                "type": "shape",
                "value": "circle",
            ],
            "shape_example3": [
                "type": "shape",
                "value": "curve_up",
            ],
            "shape_example4": [
                "type": "curve_up",
            ],
        ]
    }

    enum InvalidJSON {
        static let all: [JSONValue] = [withoutProductsBlock]

        static let withoutProductsBlock: JSONValue = [
            "footer_block": [:],
        ]
    }
}

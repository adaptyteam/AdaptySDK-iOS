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
            "footer_block": [
                "shape_example2": [
                    "type": "shape",
                    "value": "circle",
                    "order": 2,
                ],
                "shape_example1": [
                    "type": "shape",
                    "order": 1,
                ],

                "shape_example3": [
                    "type": "shape",
                    "value": "curve_up",
                    "order": 3,
                ],
                "shape_example4": [
                    "type": "curve_up",
                    "order": 4,
                ],
            ],
            "features_block": [
                          "type": "timeline",
                          "phase_0": [
                            "order": 10,
                            "type": "timeline_entry",
                            "text": [
                              "type": "text",
                              "items": [
                                [
                                  "string_id": "str-feature-0",
                                  "font": "feature-font"
                                ]
                              ],
                              "color": "primary-color",
                              "horizontal_align": "left"
                            ]
                          ],
                          //  ],
                          "phase_1": [
                            "order": 1,
                            "type": "p;timeline_entry",
                            "text": [
                              "type": "text",
                              "items": [
                                [
                                  "string_id": "str-feature-1",
                                  "font": "feature-font"
                                ]
                              ],
                              "color": "primary-color",
                              "horizontal_align": "left"
                            ]
                          ]
                        ],

//            "features_block": [
//                "type": "list",
//                "text_example": [
//                    "type": "text",
//                    "ordered": 0,
//                    "items": [
//                        [
//                            "image": "bullet",
//                            "color": "bullet-tint-color", // optional
//                            "width": 16,
//                            "height": 16,
//                            "bullet": true, // optional, default: false
//
//                        ],
//                        [
//                            "string_id": "str-feature-1",
//                            "font": "feature-font",
//                        ],
//                        [
//                            "string_id": "str-feature-2",
//                            "font": "feature-font", // optional
//                            "size": 24, // optional
//                            "color": "text-color", // optional
//                            "horizontal_align": "left", // optional, default: "left"
//                        ],
//                        [
//                            "newline": true,
//                        ],
//                        [
//                            "string_id": "str-feature-3",
//                            "font": "feature-font", // optional
//                            "size": 24, // optional
//                            "color": "text-color", // optional
//                            "horizontal_align": "left", // optional, default: "left"
//                        ],
//                        [
//                            "space": 20,
//                        ],
//                        [
//                            "string_id": "str-feature-4",
//                            "font": "feature-font",
//                        ],
//                    ],
//                    "font": "feature-font", // optional
//                    "size": 48, // optional
//                    "color": "primary-color", // optional
//                    "bullet_space": 60, // optional
//                    "horizontal_align": "left", // optional
//                ],
//            ],
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

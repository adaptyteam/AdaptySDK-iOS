//
//  AdaptyUI.ViewStyle.json.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 13.07.2023
//

@testable import Adapty

extension AdaptyUI.ViewStyle {
    enum ValidJSON {
        static let all = [short, example_1, full]

        static let short: JSONValue = [
            "products_block": [
                "type": "vertical",
            ],
        ]

        static let full: JSONValue = [
            "other": true,
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
                "other": true,
                "unknown_object": [
                    "type": "unknown_type",
                    "other": true,
                    "order": 30,
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
                "other": true,
                "type": "timeline",
                "phase_0": [
                    "order": 10,
                    "type": "timeline_entry",
                    "other": true,
                    "text": [
                        "type": "text",
                        "items": [
                            [
                                "string_id": "str-feature-0",
                                "font": "feature-font",
                            ],
                        ],
                        "color": "primary-color",
                        "horizontal_align": "left",
                    ],
                ],
                //  ],
                "phase_1": [
                    "order": 1,
                    "type": "timeline_entry",
                    "text": [
                        "type": "text",
                        "items": [
                            [
                                "string_id": "str-feature-1",
                                "font": "feature-font",
                            ],
                        ],
                        "color": "primary-color",
                        "horizontal_align": "left",
                    ],
                ],
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
                "other": true,
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

        static let example_1: JSONValue = [
            "background": "background-color",
            "title_rows": [
                "type": "text",
                "items": [
                    [
                        "font": "title-font",
                        "color": "color-title-text",
                        "string_id": "str-title",
                    ],
                    [
                        "font": "subtitle-font",
                        "color": "color-sub-title-text",
                        "string_id": "str-subhead-title",
                    ],
                ],
                "horizontal_align": "left",
            ],
            "cover_image": [
                "type": "rect",
                "background": "img-cover",
            ],
            "close_button": [
                "type": "button",
                "align": "leading",
                "action": [
                    "type": "close",
                ],
                "background": "img-close",
            ],
            "footer_block": [
                "login": [
                    "type": "button",
                    "order": 3,
                    "title": [
                        "font": "footer-font",
                        "type": "text",
                        "color": "color-footer",
                        "string_id": "str-login",
                    ],
                    "action": [
                        "type": "custom",
                        "custom_id": "login",
                    ],
                ],
                "terms": [
                    "type": "button",
                    "order": 0,
                    "title": [
                        "font": "footer-font",
                        "type": "text",
                        "color": "color-footer",
                        "string_id": "str-terms-id",
                    ],
                    "action": [
                        "url": "str-terms-url",
                        "type": "open_url",
                    ],
                ],
                "privacy": [
                    "type": "button",
                    "order": 1,
                    "title": [
                        "font": "footer-font",
                        "type": "text",
                        "color": "color-footer",
                        "string_id": "str-privacy-id",
                    ],
                    "action": [
                        "url": "str-privacy-url",
                        "type": "open_url",
                    ],
                ],
                "restore": [
                    "type": "button",
                    "order": 2,
                    "title": [
                        "font": "footer-font",
                        "type": "text",
                        "color": "color-footer",
                        "string_id": "str-restore",
                    ],
                    "action": [
                        "type": "restore",
                    ],
                ],
            ],
            "features_block": [
                "list": [
                    "color": "color-timeline-title-font",
                    "type": "text",
                    "items": [
                        [
                            "color": "color-timeline-background",
                            "image": "img-bullet",
                            "width": 16,
                            "bullet": true,
                            "height": 16,
                        ],
                        [
                            "font": "timeline-title-font",
                            "string_id": "str-timeline-start-title",
                        ],
                    ],
                    "bullet_space": 32,
                    "horizontal_align": "left",
                ],
                "type": "list",
            ],
            "products_block": [
                "type": "vertical",
                "button": [
                    "type": "button",
                    "shape": [
                        "type": "rect",
                        "background": "color-product-shape",
                        "rect_corner_radius": 8,
                    ],
                    "selected_shape": [
                        "type": "rect",
                        "border": "color-selected-shape",
                        "thickness": 1,
                        "background": "color-product-shape",
                        "rect_corner_radius": 8,
                    ],
                ],
                "product_offer": [
                    "font": "product-offer-font",
                    "type": "text",
                    "color": "color-product-offer",
                    "string_id": "str-placeholder",
                ],
                "product_price": [
                    "font": "product-title-font",
                    "type": "text",
                    "color": "color-product-title-text",
                    "string_id": "str-placeholder",
                ],
                "product_title": [
                    "font": "product-title-font",
                    "type": "text",
                    "color": "color-product-title-text",
                    "string_id": "str-placeholder",
                ],
                "horizontal_align": "leading",
                "main_product_index": 0,
                "main_product_tag_text": [
                    "font": "product-tag-font",
                    "type": "text",
                    "color": "color-main-product-tag-text",
                    "string_id": "str-product-tag",
                ],
                "main_product_tag_shape": [
                    "type": "rect",
                    "background": "color-main-product-tag-shape",
                    "rect_corner_radius": 76,
                ],
                "product_price_calculated": [
                    "font": "product-price-calc-font",
                    "type": "text",
                    "color": "color-product-price-calc",
                    "string_id": "str-placeholder",
                ],
            ],
            "purchase_button": [
                "type": "button",
                "align": "fill",
                "shape": [
                    "type": "rect",
                    "background": "color-purchase-button-shape",
                    "rect_corner_radius": 8,
                ],
                "title": [
                    "font": "purchase-button-font",
                    "type": "text",
                    "color": "color-purchase-button-text",
                    "string_id": "str-purchase-btn",
                ],
            ],
            "background_image": "img-cover",
            "main_content_shape": [
                "type": "rect",
                "background": "background-color",
                "rect_corner_radius": [20, 20, 20, 20],
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

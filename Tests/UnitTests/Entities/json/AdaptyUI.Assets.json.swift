//
//  AdaptyUI.Assets.json.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

@testable import AdaptySDK

extension AdaptyUI.Assets {
    enum ValidJSON {
        static let all = [empty, colors, example]

        static let empty: JSONValue = .array([])

        static let colors: JSONValue = .array([
            [
                "id": "white",
                "type": "color",
                "value": "#FFFFFF",
            ],
            [
                "id": "red",
                "type": "color",
                "value": "#ff0000ff",
            ],
            [
                "id": "black",
                "type": "color",
                "value": "#000000aa",
            ],
            [
                "id": "123456",
                "type": "color",
                "value": "#01234567",
            ],
        ])

        static let example: JSONValue = .array([
            [
                "id": "cover-image-0",
                "type": "image",
                "value": "base64string",
            ],
            [
                "id": "titleFont",
                "type": "font",
                "value": "SFPro Bold",
                "family_name": "SFPro",
                "size": 24,
            ],
            [
                "id": "bodyFont",
                "type": "font",
                "value": "SFPro Regular",
                "family_name": "SFPro",
                "size": 14,
            ],
            [
                "id": "productTitleFont",
                "type": "font",
                "value": "SFPro Bold",
                "family_name": "SFPro",
                "size": 18,
            ],
            [
                "id": "buttonText",
                "type": "font",
                "value": "SFPro Regular",
                "family_name": "SFPro",
                "size": 18,
            ],
            [
                "id": "accentColorF",
                "type": "color",
                "value": "#FCED0D",
            ],
            [
                "id": "accentColorS",
                "type": "color",
                "value": "#45BCFF",
            ],
            [
                "id": "buttonColorId",
                "type": "color",
                "value": "#000000",
            ],
            [
                "id": "mainProductTagId",
                "type": "color",
                "value": "#000000",
            ],
            [
                "id": "backgroundColor",
                "type": "color",
                "value": "#FFFFFF",
            ],
            [
                "id": "productBackgroundColor",
                "type": "color",
                "value": "#F3F3F3",
            ],
            [
                "id": "contrastColor",
                "type": "color",
                "value": "#000000",
            ],
            [
                "id": "textSecondaryColor",
                "type": "color",
                "value": "#696969",
            ],
            [
                "id": "checkIconColor",
                "type": "color",
                "value": "#FFFFFF",
            ],
        ])
    }

    enum InvalidJSON {
        static let all = [wrongColor1, wrongColor2]

        static let wrongColor1: JSONValue = .array([
            [
                "id": "white",
                "type": "color",
                "value": "#FF",
            ],
        ])

        static let wrongColor2: JSONValue = .array([
            [
                "id": "white",
                "type": "color",
                "value": "FFFFFF",
            ],
        ])
    }
}

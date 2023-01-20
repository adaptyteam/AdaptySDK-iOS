//
//  ViewItem.Text.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.ViewItem {
    struct Text {
        let stringId: String
        let fontAssetId: String
        let size: Double?
        let color: AdaptyUI.Color?
    }
}

extension AdaptyUI.ViewItem.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case fontAssetId = "font"
        case size = "size"
        case color = "color"
    }
}

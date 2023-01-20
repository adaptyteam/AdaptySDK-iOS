//
//  ViewItem.TextRows.swift
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
        let colorAssetId: String?
    }

    struct TextRows {
        let fontAssetId: String
        let size: Double?
        let colorAssetId: String?
        let rows: [TextRow]
    }

    struct TextRow {
        let stringId: String
        let size: Double?
        let colorAssetId: String?
    }
}

extension AdaptyUI.ViewItem.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case fontAssetId = "font"
        case size
        case colorAssetId = "color"
    }
}

extension AdaptyUI.ViewItem.TextRows: Decodable {
    enum CodingKeys: String, CodingKey {
        case rows
        case fontAssetId = "font"
        case size
        case colorAssetId = "color"
    }
}

extension AdaptyUI.ViewItem.TextRow: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case size
        case colorAssetId = "color"
    }
}

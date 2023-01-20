//
//  ViewItem.TextRows.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.ViewItem {
    struct TextRows {
        let fontAssetId: String
        let rows: [TextRow]
    }

    struct TextRow {
        let stringId: String
        var size: Double?
        var colorAssetId: String?
    }
}

extension AdaptyUI.ViewItem.TextRows: Decodable {
    enum CodingKeys: String, CodingKey {
        case rows = "rows"
        case fontAssetId = "font"
        case size = "size"
        case colorAssetId = "color"
    }


    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        fontAssetId  = try container.decode(String.self, forKey: .fontAssetId)

        let size = try container.decodeIfPresent(Double.self, forKey: .size)
        let colorAssetId = try container.decodeIfPresent(String.self, forKey: .colorAssetId)

        let rows = try container.decode([AdaptyUI.ViewItem.TextRow].self, forKey: .rows)

        if size == nil , colorAssetId == nil {
            self.rows = rows
            return
        }

        self.rows = rows.map {  row in
            var row = row

            if colorAssetId != nil, row.colorAssetId == nil   {
                row.colorAssetId = colorAssetId
            }

            if size != nil, row.size == nil   {
                row.size = size
            }

            return row
        }
    }
}

extension AdaptyUI.ViewItem.TextRow: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case size = "size"
        case colorAssetId = "color"
    }
}

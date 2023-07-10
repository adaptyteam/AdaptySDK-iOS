//
//  ViewItem.TextRows.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.ViewItem {
    struct Shape {
        let backgroundAssetId: String?
        let mask: AdaptyUI.Shape.Mask
    }

    struct Button {
        let shape: Shape?
        let title: Text?
        let align: AdaptyUI.Button.Align?
        let action: AdaptyUI.ButtonAction?
    }

    struct Text {
        let stringId: String
        let fontAssetId: String
        let size: Double?
        let fillAssetId: String?
        let horizontalAlign: AdaptyUI.HorizontalAlign?
    }

    struct TextRows {
        let fontAssetId: String
        let size: Double?
        let fillAssetId: String?
        let rows: [TextRow]
        let horizontalAlign: AdaptyUI.HorizontalAlign?
        let bulletAssetId: String?
    }

    struct TextRow {
        let stringId: String
        let fontAssetId: String
        let size: Double?
        let fillAssetId: String?
        let horizontalAlign: AdaptyUI.HorizontalAlign?
        let bulletAssetId: String?
    }
}

extension AdaptyUI.ViewItem.Shape: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case rectangleCornerRadius = "rect_corner_radius"
        case mask
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundAssetId = try container.decode(String.self, forKey: .backgroundAssetId)
        var mask = try container.decodeIfPresent(AdaptyUI.Shape.Mask.self, forKey: .mask) ?? AdaptyUI.Shape.defaultMask
        if case .rectangle = mask,
           let rectangleCornerRadius = try container.decodeIfPresent(AdaptyUI.Shape.CornerRadius.self, forKey: .rectangleCornerRadius) {
            mask = .rectangle(cornerRadius: rectangleCornerRadius)
        }
        self.mask = mask
    }
}

extension AdaptyUI.ViewItem.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case shape
        case title
        case align
        case action
    }
}

extension AdaptyUI.ViewItem.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case fontAssetId = "font"
        case size
        case fillAssetId = "color"
        case horizontalAlign = "horizontal_align"
    }
}

extension AdaptyUI.ViewItem.TextRows: Decodable {
    enum CodingKeys: String, CodingKey {
        case rows
        case fontAssetId = "font"
        case size
        case fillAssetId = "color"
        case horizontalAlign = "horizontal_align"
        case bulletAssetId = "bullet"
    }
}

extension AdaptyUI.ViewItem.TextRow: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case fontAssetId = "font"
        case size
        case fillAssetId = "color"
        case horizontalAlign = "horizontal_align"
        case bulletAssetId = "bullet"
    }
}

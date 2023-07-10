//
//  ViewItems.swift
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
        let bulletAssetId: String?
    }

    struct TextItems {
        let fontAssetId: String?
        let size: Double?
        let fillAssetId: String?
        let items: [Text]
        let horizontalAlign: AdaptyUI.HorizontalAlign?
        let bulletAssetId: String?
        let separator: AdaptyUI.Text.Separator
    }
}

extension AdaptyUI.ViewItem.TextItems {
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
        case bulletAssetId = "bullet"
    }
}

extension AdaptyUI.ViewItem.TextItems: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case rows
        case items
        case fontAssetId = "font"
        case size
        case fillAssetId = "color"
        case horizontalAlign = "horizontal_align"
        case bulletAssetId = "bullet"
        case separator
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var itemsKey = CodingKeys.items
        var defaultSeparator = AdaptyUI.TextItems.defaultSeparator

        if AdaptyUI.ViewItem.ContentType.textRows.rawValue == (try container.decode(String.self, forKey: .type)) {
            if container.contains(.rows) { itemsKey = .rows }
            defaultSeparator = .newline
        }

        fontAssetId = try container.decodeIfPresent(String.self, forKey: .fontAssetId)
        items = try container.decode([AdaptyUI.ViewItem.Text].self, forKey: itemsKey)
        size = try container.decodeIfPresent(Double.self, forKey: .size)
        fillAssetId = try container.decodeIfPresent(String.self, forKey: .fillAssetId)
        horizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlign.self, forKey: .horizontalAlign)
        bulletAssetId = try container.decodeIfPresent(String.self, forKey: .bulletAssetId)
        separator = try container.decodeIfPresent(AdaptyUI.Text.Separator.self, forKey: .separator) ?? defaultSeparator
    }
}

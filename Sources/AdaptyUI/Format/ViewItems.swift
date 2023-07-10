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
        let type: AdaptyUI.ShapeType
    }

    struct Button {
        let shape: Shape?
        let title: Text?
        let align: AdaptyUI.Button.Align?
        let action: AdaptyUI.ButtonAction?
    }

    struct Text {
        let fontAssetId: String?
        let size: Double?
        let fillAssetId: String?
        let items: [Item]
        let horizontalAlign: AdaptyUI.HorizontalAlign?
        let bulletAssetId: String?
        let separator: AdaptyUI.Text.Separator

        struct Item {
            let stringId: String
            let fontAssetId: String?
            let size: Double?
            let fillAssetId: String?
            let horizontalAlign: AdaptyUI.HorizontalAlign?
            let bulletAssetId: String?
        }
    }
}

extension AdaptyUI.ViewItem.Shape: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case rectangleCornerRadius = "rect_corner_radius"
        case type
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundAssetId = try container.decode(String.self, forKey: .backgroundAssetId)
        var shape = AdaptyUI.Shape.defaultType

        if let value = try container.decodeIfPresent(AdaptyUI.ShapeType.self, forKey: .value) {
            shape = value
        } else if let value = try? container.decode(AdaptyUI.ShapeType.self, forKey: .type) {
            shape = value
        }

        if case .rectangle = shape,
           let rectangleCornerRadius = try container.decodeIfPresent(AdaptyUI.Shape.CornerRadius.self, forKey: .rectangleCornerRadius) {
            type = .rectangle(cornerRadius: rectangleCornerRadius)
        } else {
            type = shape
        }
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

extension AdaptyUI.ViewItem.Text.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case fontAssetId = "font"
        case size
        case fillAssetId = "color"
        case horizontalAlign = "horizontal_align"
        case bulletAssetId = "bullet"
    }
}

extension AdaptyUI.ViewItem.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case rows
        case items
        case stringId = "string_id"
        case fontAssetId = "font"
        case size
        case fillAssetId = "color"
        case horizontalAlign = "horizontal_align"
        case bulletAssetId = "bullet"
        case separator
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var itemsKey: CodingKeys
        var defaultSeparator: AdaptyUI.Text.Separator

        if container.contains(.items) {
            itemsKey = .items
            defaultSeparator = .none
        } else if container.contains(.rows) {
            itemsKey = .rows
            defaultSeparator = .newline
        } else {
            itemsKey = .stringId
            defaultSeparator = .none
        }

        size = try container.decodeIfPresent(Double.self, forKey: .size)
        fillAssetId = try container.decodeIfPresent(String.self, forKey: .fillAssetId)
        horizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlign.self, forKey: .horizontalAlign)
        bulletAssetId = try container.decodeIfPresent(String.self, forKey: .bulletAssetId)
        separator = try container.decodeIfPresent(AdaptyUI.Text.Separator.self, forKey: .separator) ?? defaultSeparator

        if itemsKey == .stringId {
            fontAssetId = try container.decode(String.self, forKey: .fontAssetId)
            items = [
                AdaptyUI.ViewItem.Text.Item(
                    stringId: try container.decode(String.self, forKey: .stringId),
                    fontAssetId: nil,
                    size: nil,
                    fillAssetId: nil,
                    horizontalAlign: nil,
                    bulletAssetId: nil),
            ]
        } else {
            items = try container.decode([AdaptyUI.ViewItem.Text.Item].self, forKey: itemsKey)
            if items.contains(where: { $0.fontAssetId == nil }) {
                fontAssetId = try container.decode(String.self, forKey: .fontAssetId)
            } else {
                fontAssetId = try container.decodeIfPresent(String.self, forKey: .fontAssetId)
            }
        }
    }
}

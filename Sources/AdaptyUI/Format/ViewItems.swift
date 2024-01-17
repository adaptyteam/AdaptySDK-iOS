//
//  ViewItems.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.ViewItem {
    struct CustomObject {
        let type: String
        let properties: [(key: String, value: AdaptyUI.ViewItem)]
    }

    struct ProductObject {
        let productId: String
        let properties: [(key: String, value: AdaptyUI.ViewItem)]
    }

    struct Shape {
        let backgroundAssetId: String?
        let type: AdaptyUI.ShapeType
        let borderAssetId: String?
        let borderThickness: Double?
    }

    struct Button {
        let shape: Shape?
        let selectedShape: Shape?
        let title: Text?
        let selectedTitle: Text?
        let align: AdaptyUI.Button.Align?
        let action: AdaptyUI.ButtonAction?
        let visibility: Bool
        let transitionIn: [AdaptyUI.Transition]
    }

    struct Text {
        let fontAssetId: String?
        let size: Double?
        let fillAssetId: String?
        let items: [Item]
        let horizontalAlign: AdaptyUI.HorizontalAlign?
        let bulletSpace: Double?

        enum Item {
            case text(TextItem)
            case image(ImageItem)
            case newline
            case space(Double)
        }

        struct TextItem {
            let stringId: String
            let fontAssetId: String?
            let size: Double?
            let fillAssetId: String?
            let horizontalAlign: AdaptyUI.HorizontalAlign?
            let isBullet: Bool
        }

        struct ImageItem {
            let imageAssetId: String
            let colorAssetId: String?
            let width: Double
            let height: Double
            let isBullet: Bool
        }
    }
}

extension AdaptyUI.ViewItem.CustomObject: Decodable {
    enum PropertyKeys: String {
        case type
        case order
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        properties = try container.toOrderedItems { PropertyKeys(rawValue: $0) == nil }
        type = try container.decode(String.self, forKey: CodingKeys(PropertyKeys.type))
    }
}

extension AdaptyUI.ViewItem.ProductObject: Decodable {
    enum PropertyKeys: String {
        case type
        case productId = "product_id"
        case order
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        properties = try container.toOrderedItems { PropertyKeys(rawValue: $0) == nil }
        productId = try container.decode(String.self, forKey: CodingKeys(PropertyKeys.productId))
    }
}

extension AdaptyUI.ViewItem.Shape: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case rectangleCornerRadius = "rect_corner_radius"
        case borderAssetId = "border"
        case borderThickness = "thickness"
        case type
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundAssetId = try container.decodeIfPresent(String.self, forKey: .backgroundAssetId)
        var shape: AdaptyUI.ShapeType

        if let value = try? container.decode(AdaptyUI.ShapeType.self, forKey: .type) {
            shape = value
        } else if let value = try container.decodeIfPresent(AdaptyUI.ShapeType.self, forKey: .value) {
            shape = value
        } else {
            shape = AdaptyUI.Shape.defaultType
        }

        if case .rectangle = shape,
           let rectangleCornerRadius = try container.decodeIfPresent(AdaptyUI.Shape.CornerRadius.self, forKey: .rectangleCornerRadius) {
            type = .rectangle(cornerRadius: rectangleCornerRadius)
        } else {
            type = shape
        }

        if let assetId = try container.decodeIfPresent(String.self, forKey: .borderAssetId) {
            borderAssetId = assetId
            borderThickness = try container.decodeIfPresent(Double.self, forKey: .borderThickness)
        } else {
            borderAssetId = nil
            borderThickness = nil
        }
    }
}

extension AdaptyUI.ViewItem.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case shape
        case selectedShape = "selected_shape"
        case selectedTitle = "selected_title"
        case title
        case align
        case action
        case visibility
        case transitionIn = "transition_in"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shape = try container.decodeIfPresent(AdaptyUI.ViewItem.Shape.self, forKey: .shape)
        selectedShape = try container.decodeIfPresent(AdaptyUI.ViewItem.Shape.self, forKey: .selectedShape)
        selectedTitle = try container.decodeIfPresent(AdaptyUI.ViewItem.Text.self, forKey: .selectedTitle)
        title = try container.decodeIfPresent(AdaptyUI.ViewItem.Text.self, forKey: .title)
        align = try container.decodeIfPresent(AdaptyUI.Button.Align.self, forKey: .align)
        action = try container.decodeIfPresent(AdaptyUI.ButtonAction.self, forKey: .action)
        visibility = try container.decodeIfPresent(Bool.self, forKey: .visibility) ?? true

        if let array = try? container.decodeIfPresent([AdaptyUI.Transition].self, forKey: .transitionIn) {
            transitionIn = array
        } else if let union = try? container.decodeIfPresent(AdaptyUI.TransitionUnion.self, forKey: .transitionIn) {
            transitionIn = union.items
        } else if let transition = try container.decodeIfPresent(AdaptyUI.Transition.self, forKey: .transitionIn) {
            transitionIn = [transition]
        } else {
            transitionIn = []
        }
    }
}

extension AdaptyUI.ViewItem.Text.TextItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case fontAssetId = "font"
        case size
        case fillAssetId = "color"
        case horizontalAlign = "horizontal_align"
        case isBullet = "bullet"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stringId = try container.decode(String.self, forKey: .stringId)
        fontAssetId = try container.decodeIfPresent(String.self, forKey: .fontAssetId)
        size = try container.decodeIfPresent(Double.self, forKey: .size)
        fillAssetId = try container.decodeIfPresent(String.self, forKey: .fillAssetId)
        horizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlign.self, forKey: .horizontalAlign)
        isBullet = try container.decodeIfPresent(Bool.self, forKey: .isBullet) ?? false
    }
}

extension AdaptyUI.ViewItem.Text.ImageItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case imageAssetId = "image"
        case colorAssetId = "color"
        case width
        case height
        case isBullet = "bullet"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageAssetId = try container.decode(String.self, forKey: .imageAssetId)
        colorAssetId = try container.decodeIfPresent(String.self, forKey: .colorAssetId)
        width = try container.decode(Double.self, forKey: .width)
        height = try container.decode(Double.self, forKey: .height)
        isBullet = try container.decodeIfPresent(Bool.self, forKey: .isBullet) ?? false
    }
}

extension AdaptyUI.ViewItem.Text.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case image
        case stringId = "string_id"
        case space
        case newline
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.stringId) {
            self = .text(try AdaptyUI.ViewItem.Text.TextItem(from: decoder))
        } else if container.contains(.image) {
            self = .image(try AdaptyUI.ViewItem.Text.ImageItem(from: decoder))
        } else if container.contains(.newline) {
            self = .newline
        } else {
            self = .space(try container.decodeIfPresent(Double.self, forKey: .space) ?? 0.0)
        }
    }
}

extension AdaptyUI.ViewItem.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case items
        case stringId = "string_id"
        case fontAssetId = "font"
        case size
        case fillAssetId = "color"
        case horizontalAlign = "horizontal_align"
        case bulletSpace = "bullet_space"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        size = try container.decodeIfPresent(Double.self, forKey: .size)
        fillAssetId = try container.decodeIfPresent(String.self, forKey: .fillAssetId)
        horizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlign.self, forKey: .horizontalAlign)

        if container.contains(.items) {
            items = try container.decode([AdaptyUI.ViewItem.Text.Item].self, forKey: .items)
            if items.compactMap({
                if case let .text(item) = $0 { return item }
                return nil
            }).contains(where: { $0.fontAssetId == nil }) {
                fontAssetId = try container.decode(String.self, forKey: .fontAssetId)
            } else {
                fontAssetId = try container.decodeIfPresent(String.self, forKey: .fontAssetId)
            }
            if items.contains(where: {
                if case let .image(item) = $0 { return item.isBullet }
                if case let .text(item) = $0 { return item.isBullet }
                return false
            }) {
                bulletSpace = try container.decode(Double.self, forKey: .bulletSpace)
            } else {
                bulletSpace = try container.decodeIfPresent(Double.self, forKey: .bulletSpace)
            }
        } else {
            fontAssetId = try container.decode(String.self, forKey: .fontAssetId)
            bulletSpace = try container.decodeIfPresent(Double.self, forKey: .bulletSpace)
            items = [.text(AdaptyUI.ViewItem.Text.TextItem(
                stringId: try container.decode(String.self, forKey: .stringId),
                fontAssetId: nil,
                size: nil,
                fillAssetId: nil,
                horizontalAlign: nil,
                isBullet: false
            ))]
        }
    }
}

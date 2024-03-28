//
//  VC.OldText.swift
//
//
//  Created by Aleksei Valiano on 25.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    typealias Text = TextBlock
    struct OldText {
        let fontAssetId: String?
        let size: Double?
        let fillAssetId: String?
        let items: [Item]
        let horizontalAlign: AdaptyUI.HorizontalAlignment?
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
            let horizontalAlign: AdaptyUI.HorizontalAlignment?
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

extension AdaptyUI.ViewConfiguration.Localizer {
    func richText(from _: AdaptyUI.ViewConfiguration.OldText) -> AdaptyUI.RichText {
        AdaptyUI.RichText.empty
    }
}

extension AdaptyUI.ViewConfiguration.OldText.TextItem: Decodable {
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
        horizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlignment.self, forKey: .horizontalAlign)
        isBullet = try container.decodeIfPresent(Bool.self, forKey: .isBullet) ?? false
    }
}

extension AdaptyUI.ViewConfiguration.OldText.ImageItem: Decodable {
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

extension AdaptyUI.ViewConfiguration.OldText.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case image
        case stringId = "string_id"
        case space
        case newline
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.stringId) {
            self = try .text(AdaptyUI.ViewConfiguration.OldText.TextItem(from: decoder))
        } else if container.contains(.image) {
            self = try .image(AdaptyUI.ViewConfiguration.OldText.ImageItem(from: decoder))
        } else if container.contains(.newline) {
            self = .newline
        } else {
            self = try .space(container.decodeIfPresent(Double.self, forKey: .space) ?? 0.0)
        }
    }
}

extension AdaptyUI.ViewConfiguration.OldText: Decodable {
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
        horizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlignment.self, forKey: .horizontalAlign)

        if container.contains(.items) {
            items = try container.decode([AdaptyUI.ViewConfiguration.OldText.Item].self, forKey: .items)
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
            items = try [.text(AdaptyUI.ViewConfiguration.OldText.TextItem(
                stringId: container.decode(String.self, forKey: .stringId),
                fontAssetId: nil,
                size: nil,
                fillAssetId: nil,
                horizontalAlign: nil,
                isBullet: false
            ))]
        }
    }
}

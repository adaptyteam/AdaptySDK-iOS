//
//  File.swift
//
//
//  Created by Aleksei Valiano on 15.03.2024
//
//

import Foundation

// TODO: public let bulletSpace: Double? ,
//       public let textBullet ,
//       public let imageBullet
extension AdaptyUI.ViewConfiguration {
    struct TextAttributes {
        let fontAssetId: String?
        let size: Double?
        let colorAssetId: String?
        let backgroundAssetId: String?
        let strike: Bool?
        let underline: Bool?
    }

    struct ParagraphAttributes {
        let horizontalAlign: AdaptyUI.HorizontalAlign?
        let firstIndent: Double?
        let indent: Double?
    }

    struct ImageInTextAttributes {
        let size: Double?
        let tintAssetId: String?
        let backgroundAssetId: String?
        let strike: Bool?
        let underline: Bool?
    }

    struct RichText {
        let items: [RichText.Item]

        var isEmpty: Bool { items.isEmpty }

        enum Item {
            case text(String, TextAttributes?)
            case tag(String, TextAttributes?)
            case paragraph(ParagraphAttributes?)
            case image(String, ImageInTextAttributes?)
            case unknown
        }
    }
}

extension [AdaptyUI.ViewConfiguration.RichText.Item] {
    var asString: String? {
        let string = compactMap {
            switch $0 {
            case let .text(value, _), let .tag(value, _): value
            case .paragraph: "\n"
            default: nil
            }
        }.joined()

        return string.isEmpty ? nil : string
    }
}

extension AdaptyUI.ViewConfiguration.RichText {
    var asString: String? {
        items.asString
    }

    func convert(
        _ assetById: (String?) -> AdaptyUI.ViewConfiguration.Asset?,
        defTextAttributes: AdaptyUI.ViewConfiguration.TextAttributes? = nil,
        defParagraphAttributes: AdaptyUI.ViewConfiguration.ParagraphAttributes? = nil,
        defImageInTextAttributes: AdaptyUI.ViewConfiguration.ImageInTextAttributes? = nil
    ) -> [AdaptyUI.RichText.Item] {
        items.compactMap { item in
            switch item {
            case let .text(value, attr):
                .text(value, attr.map { $0.convert(assetById, def: defTextAttributes) })
            case let .tag(value, attr):
                .tag(value, attr.map { $0.convert(assetById, def: defTextAttributes) })
            case let .paragraph(attr):
                .paragraph(attr.map { $0.convert(assetById, def: defParagraphAttributes) })
            case let .image(assetId, attr):
                .image(assetById(assetId)?.asFilling?.asImage, attr.map { $0.convert(assetById, def: defImageInTextAttributes) })
            default:
                nil
            }
        }
    }
}

extension AdaptyUI.ViewConfiguration.TextAttributes {
    func convert(_ assetById: (String?) -> AdaptyUI.ViewConfiguration.Asset?, def: Self?) -> AdaptyUI.RichText.TextAttributes {
        .init(
            font: assetById(fontAssetId ?? def?.fontAssetId)?.asFont,
            size: size ?? def?.size,
            color: assetById(colorAssetId ?? def?.colorAssetId)?.asFilling,
            background: assetById(backgroundAssetId ?? def?.backgroundAssetId)?.asFilling,
            strike: strike ?? def?.strike,
            underline: underline ?? def?.underline
        )
    }
}

extension AdaptyUI.ViewConfiguration.ParagraphAttributes {
    func convert(_: (String?) -> AdaptyUI.ViewConfiguration.Asset?, def: Self?) -> AdaptyUI.RichText.ParagraphAttributes {
        .init(
            horizontalAlign: horizontalAlign ?? def?.horizontalAlign,
            firstIndent: firstIndent ?? def?.firstIndent,
            indent: indent ?? def?.indent
        )
    }
}

extension AdaptyUI.ViewConfiguration.ImageInTextAttributes {
    func convert(_ assetById: (String?) -> AdaptyUI.ViewConfiguration.Asset?, def: Self?) -> AdaptyUI.RichText.ImageInTextAttributes {
        .init(
            size: size ?? def?.size,
            tint: assetById(tintAssetId ?? def?.tintAssetId)?.asFilling,
            background: assetById(backgroundAssetId ?? def?.backgroundAssetId)?.asFilling,
            strike: strike ?? def?.strike,
            underline: underline ?? def?.underline
        )
    }
}

extension AdaptyUI.ViewConfiguration.RichText: Decodable {
    init(from decoder: Decoder) throws {
        if let value = try? Item(from: decoder) {
            items = [value]
            return
        }
        items = try [Item](from: decoder)
    }
}

extension AdaptyUI.ViewConfiguration.RichText.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case text
        case tag
        case paragraph
        case image
        case attributes
    }

    init(from decoder: Decoder) throws {
        if let value = try? (try? decoder.singleValueContainer())?.decode(String.self) {
            self = .text(value, nil)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.text) {
            self = try .text(
                container.decode(String.self, forKey: .text),
                container.decodeIfPresent(AdaptyUI.ViewConfiguration.TextAttributes.self, forKey: .attributes)
            )
        } else if container.contains(.tag) {
            self = try .tag(
                container.decode(String.self, forKey: .tag),
                container.decodeIfPresent(AdaptyUI.ViewConfiguration.TextAttributes.self, forKey: .attributes)
            )
        } else if container.contains(.paragraph) {
            self = try .paragraph(container.decodeIfPresent(AdaptyUI.ViewConfiguration.ParagraphAttributes.self, forKey: .paragraph))
        } else if container.contains(.image) {
            self = try .image(
                container.decode(String.self, forKey: .image),
                container.decodeIfPresent(AdaptyUI.ViewConfiguration.ImageInTextAttributes.self, forKey: .attributes)
            )
        } else {
            self = .unknown
        }
    }
}

extension AdaptyUI.ViewConfiguration.TextAttributes: Decodable {
    enum CodingKeys: String, CodingKey {
        case size
        case fontAssetId = "font"
        case colorAssetId = "color"
        case backgroundAssetId = "background"
        case strike
        case underline
    }
}

extension AdaptyUI.ViewConfiguration.ParagraphAttributes: Decodable {
    enum CodingKeys: String, CodingKey {
        case horizontalAlign = "align"
        case firstIndent = "first_indent"
        case indent
    }
}

extension AdaptyUI.ViewConfiguration.ImageInTextAttributes: Decodable {
    enum CodingKeys: String, CodingKey {
        case size
        case tintAssetId = "tint"
        case backgroundAssetId = "background"
        case strike
        case underline
    }
}

//
//  VC.RichText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 15.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct TextAttributes {
        let fontAssetId: String?
        let size: Double?
        let colorAssetId: String?
        let backgroundAssetId: String?
        let strike: Bool?
        let underline: Bool?

        var isEmpty: Bool {
            fontAssetId == nil
                && size == nil
                && colorAssetId == nil
                && backgroundAssetId == nil
                && strike == nil
                && underline == nil
        }
    }

    struct ParagraphAttributes {
        let horizontalAlign: AdaptyUI.HorizontalAlignment?
        let firstIndent: Double?
        let indent: Double?
        let bulletSpace: Double?

        var isEmpty: Bool {
            horizontalAlign == nil
                && firstIndent == nil
                && indent == nil
                && bulletSpace == nil
        }
    }

    struct RichText {
        let items: [RichText.Item]

        var isEmpty: Bool { items.isEmpty }

        enum Bullet {
            case text(String, TextAttributes?)
            case image(String, TextAttributes?)
            case unknown
        }

        enum Item {
            case text(String, TextAttributes?)
            case tag(String, TextAttributes?)
            case paragraph(ParagraphAttributes, Bullet?)
            case image(String, TextAttributes?)
            case unknown
        }
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func urlIfPresent(_ stringId: String?) -> String? {
        guard let stringId, let item = self.localization?.strings?[stringId] else { return nil }
        return item.value.asString ?? item.fallback?.asString
    }

    func richTextIfPresent(_ stringId: String?) -> AdaptyUI.RichText? {
        guard let stringId, let item = localization?.strings?[stringId] else { return nil }
        return AdaptyUI.RichText(
            items: item.value.convert(self),
            fallback: item.fallback.map { $0.convert(self) }
        )
    }
}

extension AdaptyUI.ViewConfiguration.RichText {
    var asString: String? {
        items.first.flatMap {
            if case let .text(value, attr) = $0, attr == nil { value } else { nil }
        }
    }

    func convert(
        _ localizer: AdaptyUI.ViewConfiguration.Localizer,
        defaultTextAttributes: AdaptyUI.ViewConfiguration.TextAttributes? = nil,
        defaultParagraphAttributes: AdaptyUI.ViewConfiguration.ParagraphAttributes? = nil
    ) -> [AdaptyUI.RichText.Item] {
        items.compactMap { item in
            switch item {
            case let .text(value, attr):
                .text(value, attr.add(defaultTextAttributes).convert(localizer))
            case let .tag(value, attr):
                .tag(value, attr.add(defaultTextAttributes).convert(localizer))
            case let .paragraph(attr, bullet):
                .paragraph(attr.add(defaultParagraphAttributes).convert(
                    bullet.flatMap { $0.convert(localizer, defaultTextAttributes: defaultTextAttributes) }
                ))
            case let .image(assetId, attr):
                .image(localizer.imageData(assetId), attr.add(defaultTextAttributes).convert(localizer))
            default:
                nil
            }
        }
    }
}

private extension AdaptyUI.ViewConfiguration.RichText.Bullet {
    func convert(
        _ localizer: AdaptyUI.ViewConfiguration.Localizer,
        defaultTextAttributes: AdaptyUI.ViewConfiguration.TextAttributes? = nil
    ) -> AdaptyUI.RichText.Bullet? {
        switch self {
        case let .text(value, attr):
            .text(value, attr.add(defaultTextAttributes).convert(localizer))
        case let .image(assetId, attr):
            .image(localizer.imageData(assetId), attr.add(defaultTextAttributes).convert(localizer))
        default:
            nil
        }
    }
}

private extension AdaptyUI.ViewConfiguration.TextAttributes {
    func _add(_ other: AdaptyUI.ViewConfiguration.TextAttributes?) -> AdaptyUI.ViewConfiguration.TextAttributes {
        guard let other else { return self }
        return .init(
            fontAssetId: fontAssetId ?? other.fontAssetId,
            size: size ?? other.size,
            colorAssetId: colorAssetId ?? other.colorAssetId,
            backgroundAssetId: backgroundAssetId ?? other.backgroundAssetId,
            strike: strike ?? other.strike,
            underline: underline ?? other.underline
        )
    }
}

private extension AdaptyUI.ViewConfiguration.ParagraphAttributes {
    func add(_ other: AdaptyUI.ViewConfiguration.ParagraphAttributes?) -> AdaptyUI.ViewConfiguration.ParagraphAttributes {
        guard let other else { return self }
        return .init(
            horizontalAlign: horizontalAlign ?? other.horizontalAlign,
            firstIndent: firstIndent ?? other.firstIndent,
            indent: indent ?? other.indent,
            bulletSpace: bulletSpace ?? other.bulletSpace
        )
    }

    func convert(
        _ bullet: AdaptyUI.RichText.Bullet?
    ) -> AdaptyUI.RichText.ParagraphAttributes {
        let indent = self.indent ?? 0
        let firstIndent = self.firstIndent ?? indent
        return AdaptyUI.RichText.ParagraphAttributes(
            horizontalAlign: self.horizontalAlign ?? .left,
            firstIndent: firstIndent,
            indent: indent,
            bulletSpace: self.bulletSpace,
            bullet: bullet
        )
    }
}

private extension AdaptyUI.ViewConfiguration.TextAttributes? {
    func add(_ other: AdaptyUI.ViewConfiguration.TextAttributes?) -> AdaptyUI.ViewConfiguration.TextAttributes? {
        switch self {
        case .none:
            other
        case let .some(value):
            value._add(other)
        }
    }

    func convert(_ localizer: AdaptyUI.ViewConfiguration.Localizer) -> AdaptyUI.RichText.TextAttributes {
        let attr = self
        let font = localizer.font(attr?.fontAssetId)
        return AdaptyUI.RichText.TextAttributes(
            font: font,
            size: attr?.size ?? font.defaultSize,
            color: localizer.fillingIfPresent(attr?.colorAssetId) ?? font.defaultFilling,
            background: localizer.fillingIfPresent(attr?.backgroundAssetId),
            strike: attr?.strike ?? false,
            underline: attr?.underline ?? false
        )
    }
}

extension AdaptyUI.ViewConfiguration.RichText: Decodable {
    init(from decoder: Decoder) throws {
        items =
            if let value = try? Item(from: decoder) {
                [value]
            } else {
                try [Item](from: decoder)
            }
    }
}

extension AdaptyUI.ViewConfiguration.RichText.Bullet: Decodable {
    init(from decoder: Decoder) throws {
        self =
            switch try AdaptyUI.ViewConfiguration.RichText.Item(from: decoder) {
            case let .text(assetId, attr): .text(assetId, attr)
            case let .image(assetId, attr): .image(assetId, attr)
            default: .unknown
            }
    }
}

extension AdaptyUI.ViewConfiguration.RichText.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case text
        case tag
        case paragraph
        case bullet
        case image
        case attributes
    }

    init(from decoder: Decoder) throws {
        if let value = try? (try? decoder.singleValueContainer())?.decode(String.self) {
            self = .text(value, nil)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self =
            if container.contains(.text) {
                try .text(
                    container.decode(String.self, forKey: .text),
                    container.decodeIfPresent(AdaptyUI.ViewConfiguration.TextAttributes.self, forKey: .attributes)
                )
            } else if container.contains(.tag) {
                try .tag(
                    container.decode(String.self, forKey: .tag),
                    container.decodeIfPresent(AdaptyUI.ViewConfiguration.TextAttributes.self, forKey: .attributes)
                )
            } else if container.contains(.paragraph) {
                try .paragraph(
                    container.decode(AdaptyUI.ViewConfiguration.ParagraphAttributes.self, forKey: .paragraph),
                    container.decodeIfPresent(AdaptyUI.ViewConfiguration.RichText.Bullet.self, forKey: .bullet)
                )
            } else if container.contains(.image) {
                try .image(
                    container.decode(String.self, forKey: .image),
                    container.decodeIfPresent(AdaptyUI.ViewConfiguration.TextAttributes.self, forKey: .attributes)
                )
            } else {
                .unknown
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
        case bulletSpace = "bullet_space"
    }
}

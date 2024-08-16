//
//  VC.RichText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 15.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct TextAttributes: Sendable, Hashable {
        let fontAssetId: String?
        let size: Double?
        let txtColorAssetId: String?
        let imgTintColorAssetId: String?
        let backgroundAssetId: String?
        let strike: Bool?
        let underline: Bool?

        var isEmpty: Bool {
            fontAssetId == nil
                && size == nil
                && txtColorAssetId == nil
                && imgTintColorAssetId == nil
                && backgroundAssetId == nil
                && strike == nil
                && underline == nil
        }
    }

    struct RichText: Sendable, Hashable {
        let items: [RichText.Item]

        var isEmpty: Bool { items.isEmpty }

        enum Item: Sendable {
            case text(String, TextAttributes?)
            case tag(String, TextAttributes?)
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

    func richText(
        stringId: String,
        defaultTextAttributes: AdaptyUI.ViewConfiguration.TextAttributes?
    ) -> AdaptyUI.RichText? {
        guard let item = localization?.strings?[stringId] else { return nil }
        return AdaptyUI.RichText(
            items: item.value.convert(
                self,
                defaultTextAttributes: defaultTextAttributes
            ),
            fallback: item.fallback.map { $0.convert(
                self,
                defaultTextAttributes: defaultTextAttributes
            ) }
        )
    }
}

private extension AdaptyUI.ViewConfiguration.RichText {
    var asString: String? {
        items.first.flatMap {
            if case let .text(value, attr) = $0, attr == nil { value } else { nil }
        }
    }

    func convert(
        _ localizer: AdaptyUI.ViewConfiguration.Localizer,
        defaultTextAttributes: AdaptyUI.ViewConfiguration.TextAttributes?
    ) -> [AdaptyUI.RichText.Item] {
        items.compactMap { item in
            switch item {
            case let .text(value, attr):
                .text(value, attr.add(defaultTextAttributes).convert(localizer))
            case let .tag(value, attr):
                .tag(value, attr.add(defaultTextAttributes).convert(localizer))
            case let .image(assetId, attr):
                .image(try? localizer.imageData(assetId), attr.add(defaultTextAttributes).convert(localizer))
            default:
                nil
            }
        }
    }
}

private extension AdaptyUI.ViewConfiguration.TextAttributes {
    func add(
        _ other: AdaptyUI.ViewConfiguration.TextAttributes?
    ) -> AdaptyUI.ViewConfiguration.TextAttributes {
        guard let other else { return self }
        return AdaptyUI.ViewConfiguration.TextAttributes(
            fontAssetId: fontAssetId ?? other.fontAssetId,
            size: size ?? other.size,
            txtColorAssetId: txtColorAssetId ?? other.txtColorAssetId,
            imgTintColorAssetId: imgTintColorAssetId ?? other.imgTintColorAssetId,
            backgroundAssetId: backgroundAssetId ?? other.backgroundAssetId,
            strike: strike ?? other.strike,
            underline: underline ?? other.underline
        )
    }
}

private extension AdaptyUI.ViewConfiguration.TextAttributes? {
    func add(
        _ other: AdaptyUI.ViewConfiguration.TextAttributes?
    ) -> AdaptyUI.ViewConfiguration.TextAttributes? {
        switch self {
        case .none:
            other
        case let .some(value):
            value.add(other)
        }
    }

    func convert(
        _ localizer: AdaptyUI.ViewConfiguration.Localizer
    ) -> AdaptyUI.RichText.TextAttributes {
        let attr = self
        let font = (try? attr?.fontAssetId.map(localizer.font)) ?? AdaptyUI.Font.default
        return AdaptyUI.RichText.TextAttributes(
            font: font,
            size: attr?.size ?? font.defaultSize,
            txtColor: (try? attr?.txtColorAssetId.map(localizer.colorFilling)) ?? font.defaultColor,
            imgTintColor: try? attr?.imgTintColorAssetId.map(localizer.colorFilling),
            background: try? attr?.backgroundAssetId.map(localizer.colorFilling),
            strike: attr?.strike ?? false,
            underline: attr?.underline ?? false
        )
    }
}

extension AdaptyUI.ViewConfiguration.RichText.Item: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value, attr):
            hasher.combine(1)
            hasher.combine(value)
            hasher.combine(attr)
        case let .tag(value, attr):
            hasher.combine(2)
            hasher.combine(value)
            hasher.combine(attr)
        case let .image(value, attr):
            hasher.combine(3)
            hasher.combine(value)
            hasher.combine(attr)
        case .unknown:
            hasher.combine(4)
        }
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

extension AdaptyUI.ViewConfiguration.RichText.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case text
        case tag
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
        case txtColorAssetId = "color"
        case imgTintColorAssetId = "tint"
        case backgroundAssetId = "background"
        case strike
        case underline
    }
}

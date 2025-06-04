//
//  VC.RichText.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 15.03.2024
//
//

import Foundation

extension AdaptyViewSource {
    struct TextAttributes: Sendable, Hashable {
        let fontAssetId: String?
        let size: Double?
        let txtColorAssetId: String?
        let imageTintColorAssetId: String?
        let backgroundAssetId: String?
        let strike: Bool?
        let underline: Bool?

        var isEmpty: Bool {
            fontAssetId == nil
                && size == nil
                && txtColorAssetId == nil
                && imageTintColorAssetId == nil
                && backgroundAssetId == nil
                && (strike ?? false) == false
                && (underline ?? false) == false
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

extension AdaptyViewSource.Localizer {
    func urlIfPresent(_ stringId: String?) -> String? {
        guard let stringId, let item = localization?.strings?[stringId] else { return nil }
        return item.value.asString ?? item.fallback?.asString
    }

    func richText(
        stringId: String,
        defaultTextAttributes: AdaptyViewSource.TextAttributes?
    ) -> AdaptyViewConfiguration.RichText? {
        guard let item = localization?.strings?[stringId] else { return nil }
        return AdaptyViewConfiguration.RichText(
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

private extension AdaptyViewSource.RichText {
    var asString: String? {
        items.first.flatMap {
            if case let .text(value, attributes) = $0, attributes == nil { value } else { nil }
        }
    }

    func convert(
        _ localizer: AdaptyViewSource.Localizer,
        defaultTextAttributes: AdaptyViewSource.TextAttributes?
    ) -> [AdaptyViewConfiguration.RichText.Item] {
        items.compactMap { item in
            switch item {
            case let .text(value, attributes):
                .text(value, attributes.add(defaultTextAttributes).convert(localizer))
            case let .tag(value, attributes):
                .tag(value, attributes.add(defaultTextAttributes).convert(localizer))
            case let .image(assetId, attributes):
                .image(try? localizer.imageData(assetId), attributes.add(defaultTextAttributes).convert(localizer))
            default:
                nil
            }
        }
    }
}

private extension AdaptyViewSource.TextAttributes {
    func add(
        _ other: AdaptyViewSource.TextAttributes?
    ) -> AdaptyViewSource.TextAttributes {
        guard let other else { return self }
        return AdaptyViewSource.TextAttributes(
            fontAssetId: fontAssetId ?? other.fontAssetId,
            size: size ?? other.size,
            txtColorAssetId: txtColorAssetId ?? other.txtColorAssetId,
            imageTintColorAssetId: imageTintColorAssetId ?? other.imageTintColorAssetId,
            backgroundAssetId: backgroundAssetId ?? other.backgroundAssetId,
            strike: strike ?? other.strike,
            underline: underline ?? other.underline
        )
    }
}

private extension AdaptyViewSource.TextAttributes? {
    func add(
        _ other: AdaptyViewSource.TextAttributes?
    ) -> AdaptyViewSource.TextAttributes? {
        switch self {
        case .none:
            other
        case let .some(value):
            value.add(other)
        }
    }

    func convert(
        _ localizer: AdaptyViewSource.Localizer
    ) -> AdaptyViewConfiguration.RichText.TextAttributes {
        let attributes = self
        let font = (try? attributes?.fontAssetId.map(localizer.font)) ?? AdaptyViewConfiguration.Font.default
        return AdaptyViewConfiguration.RichText.TextAttributes(
            font: font,
            size: attributes?.size ?? font.defaultSize,
            txtColor: (try? attributes?.txtColorAssetId.map(localizer.filling)) ?? .same(font.defaultColor),
            imageTintColor: try? attributes?.imageTintColorAssetId.map(localizer.filling),
            background: try? attributes?.backgroundAssetId.map(localizer.filling),
            strike: attributes?.strike ?? false,
            underline: attributes?.underline ?? false
        )
    }
}

extension AdaptyViewSource.RichText.Item: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value, attributes):
            hasher.combine(1)
            hasher.combine(value)
            hasher.combine(attributes)
        case let .tag(value, attributes):
            hasher.combine(2)
            hasher.combine(value)
            hasher.combine(attributes)
        case let .image(value, attributes):
            hasher.combine(3)
            hasher.combine(value)
            hasher.combine(attributes)
        case .unknown:
            hasher.combine(4)
        }
    }
}

extension AdaptyViewSource.RichText: Codable {
    init(from decoder: Decoder) throws {
        items =
            if let value = try? Item(from: decoder) {
                [value]
            } else {
                try [Item](from: decoder)
            }
    }

    func encode(to encoder: any Encoder) throws {
        let items = items.filter {
            if case .unknown = $0 { false } else { true }
        }
        if items.count == 1 {
            try items[0].encode(to: encoder)
        } else {
            try items.encode(to: encoder)
        }
    }
}

extension AdaptyViewSource.RichText.Item: Codable {
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
                    container.decodeIfPresent(AdaptyViewSource.TextAttributes.self, forKey: .attributes)
                )
            } else if container.contains(.tag) {
                try .tag(
                    container.decode(String.self, forKey: .tag),
                    container.decodeIfPresent(AdaptyViewSource.TextAttributes.self, forKey: .attributes)
                )
            } else if container.contains(.image) {
                try .image(
                    container.decode(String.self, forKey: .image),
                    container.decodeIfPresent(AdaptyViewSource.TextAttributes.self, forKey: .attributes)
                )
            } else {
                .unknown
            }
    }

    func encode(to encoder: any Encoder) throws {
        switch self {
        case let .text(text, attributes):
            guard let attributes, !attributes.isEmpty else {
                var container = encoder.singleValueContainer()
                try container.encode(text)
                return
            }
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(text, forKey: .text)
            try container.encode(attributes, forKey: .attributes)
        case let .tag(tag, attributes):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(tag, forKey: .tag)
            if let attributes, !attributes.isEmpty {
                try container.encode(attributes, forKey: .attributes)
            }
        case let .image(image, attributes):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(image, forKey: .image)
            if let attributes, !attributes.isEmpty {
                try container.encode(attributes, forKey: .attributes)
            }
        case .unknown:
            break
        }
    }
}

extension AdaptyViewSource.TextAttributes: Codable {
    enum CodingKeys: String, CodingKey {
        case size
        case fontAssetId = "font"
        case txtColorAssetId = "color"
        case imageTintColorAssetId = "tint"
        case backgroundAssetId = "background"
        case strike
        case underline
    }
}

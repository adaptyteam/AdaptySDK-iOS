//
//  AdaptyUISchema.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

public struct AdaptyUISchema: Sendable {
    let formatVersion: String
    let templateId: String
    let templateRevision: Int64
    let assets: [String: Asset]
    let localizations: [LocaleId: Localization]
    let defaultLocalization: Localization?
    let defaultScreen: Screen
    let screens: [String: Screen]
    let referencedElements: [String: Element]
    let selectedProducts: [String: String]
}

extension AdaptyUISchema: CustomStringConvertible {
    public var description: String {
        "(formatVersion: \(formatVersion), templateId: \(templateId), templateRevision: \(templateRevision))"
    }
}

extension AdaptyUISchema: Codable {
    private enum CodingKeys: String, CodingKey {
        case formatVersion = "format"
        case templateId = "template_id"
        case templateRevision = "template_revision"
        case assets
        case localizations
        case defaultLocalId = "default_localization"
        case screens = "styles"
        case defaultScreen = "default"
        case products
        case selected
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        templateId = try container.decode(String.self, forKey: .templateId)
        templateRevision = try container.decode(Int64.self, forKey: .templateRevision)
        formatVersion = try container.decode(String.self, forKey: .formatVersion)

        if container.contains(.products) {
            let products = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .products)
            if let selected = try? products.decodeIfPresent(String.self, forKey: .selected) {
                selectedProducts = [Schema.StringId.Product.defaultProductGroupId: selected]
            } else {
                selectedProducts = try products.decode([String: String].self, forKey: .selected)
            }
        } else {
            selectedProducts = [:]
        }

        assets = try (container.decodeIfPresent(AssetsContainer.self, forKey: .assets))?.value ?? [:]

        let localizationsArray = try container.decodeIfPresent([Localization].self, forKey: .localizations) ?? []
        let localizations = try [LocaleId: Localization](localizationsArray.map { ($0.id, $0) }, uniquingKeysWith: { _, _ in
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.localizations], debugDescription: "Duplicate id"))
        })
        self.localizations = localizations
        if let defaultLocalId = try container.decodeIfPresent(LocaleId.self, forKey: .defaultLocalId) {
            defaultLocalization = localizations[defaultLocalId]
        } else {
            defaultLocalization = nil
        }

        let screens = try container.decode([String: Screen].self, forKey: .screens)
        guard let defaultScreen = screens[CodingKeys.defaultScreen.rawValue] else {
            throw DecodingError.valueNotFound(Screen.self, DecodingError.Context(codingPath: container.codingPath + [CodingKeys.screens, CodingKeys.defaultScreen], debugDescription: "Expected Screen value but do not found"))
        }
        self.defaultScreen = defaultScreen
        self.screens = screens.filter { $0.key != CodingKeys.defaultScreen.rawValue }
        referencedElements = try [String: Element](screens.flatMap { $0.value.referencedElements }, uniquingKeysWith: { _, _ in
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.localizations], debugDescription: "Duplicate element_id"))
        })
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(templateId, forKey: .templateId)
        try container.encode(templateRevision, forKey: .templateRevision)
        try container.encode(formatVersion, forKey: .formatVersion)

        if !selectedProducts.isEmpty {
            var products = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .products)
            try products.encode(selectedProducts, forKey: .selected)
        }

        try container.encode(AssetsContainer(value: assets), forKey: .assets)

        try container.encode(Array(localizations.values), forKey: .localizations)
        try container.encodeIfPresent(defaultLocalization?.id, forKey: .defaultLocalId)

        var screens = screens
        screens[CodingKeys.defaultScreen.rawValue] = defaultScreen
        try container.encode(screens, forKey: .screens)
    }
}

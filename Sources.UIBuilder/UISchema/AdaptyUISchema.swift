//
//  AdaptyUISchema.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

typealias Schema = AdaptyUISchema

public struct AdaptyUISchema: Sendable {
    let formatVersion: Version
    let templateId: String
    let assets: [String: Asset]
    let localizations: [LocaleId: Localization]
    let defaultLocalization: Localization?
    let defaultScreen: Screen
    let screens: [String: Screen]
    let templates: any AdaptyUISchemaTemplates
}

extension AdaptyUISchema: CustomStringConvertible {
    public var description: String {
        "(formatVersion: \(formatVersion), templateId: \(templateId))"
    }
}

public extension AdaptyUISchema {
    init(from jsonData: Data) throws {
        self = try JSONDecoder().decode(AdaptyUISchema.self, from: jsonData)
    }

    init(from jsonData: String) throws {
        try self.init(from: jsonData.data(using: .utf8) ?? Data())
    }
}

extension AdaptyUISchema: Codable {
    struct DecodingConfiguration {
        let isLegacy: Bool
        var insideTemplate = false
    }

    private enum CodingKeys: String, CodingKey {
        case formatVersion = "format"
        case templateId = "template_id"
        case assets
        case localizations
        case defaultLocalId = "default_localization"
        case templates
        case legacyScreens = "styles"
        case screens

        case products
        case selected
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        templateId = try container.decode(String.self, forKey: .templateId)
        formatVersion = try container.decode(Version.self, forKey: .formatVersion)

        let configuration = DecodingConfiguration(isLegacy: !formatVersion.isNotLegacyVersion)

        if container.contains(.products) {
            var selectedProducts = [String: String]()
            let products = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .products)
            if let selected = try? products.decodeIfPresent(String.self, forKey: .selected) {
                selectedProducts = ["group_A": selected]
            } else {
                selectedProducts = try products.decode([String: String].self, forKey: .selected)
            }
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

        let screensCollection = try container.decode(
            ScreensCollection.self,
            forKey: configuration.isLegacy ? .legacyScreens : .screens,
            configuration: configuration
        )

        let templatesCollection = try container.decode(
            TemplatesCollection.self,
            forKey: .templates,
            configuration: configuration
        )

        guard let defaultScreen = screensCollection.defaultScreen else {
            throw DecodingError.valueNotFound(Screen.self, DecodingError.Context(codingPath: container.codingPath + [CodingKeys.screens, AnyCodingKey(stringValue: ScreensCollection.defaultScreenKey)], debugDescription: "Expected Screen value but do not found"))
        }
        self.defaultScreen = defaultScreen
        screens = screensCollection.values

        templates = try Schema.createTemplates(
            formatVersion: formatVersion,
            templatesCollection: templatesCollection,
            screens: screensCollection.values
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(templateId, forKey: .templateId)
        try container.encode(formatVersion, forKey: .formatVersion)

        try container.encode(AssetsContainer(value: assets), forKey: .assets)

        try container.encode(Array(localizations.values), forKey: .localizations)
        try container.encodeIfPresent(defaultLocalization?.id, forKey: .defaultLocalId)

        try container.encode(screens, forKey: .screens)
    }
}

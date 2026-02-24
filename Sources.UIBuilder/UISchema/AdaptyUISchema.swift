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
    let assets: [AssetIdentifier: Asset]
    let localizations: [LocaleId: Localization]
    let defaultLocalization: Localization?
    let navigators: [NavigatorIdentifier: Navigator]
    let screens: [ScreenType: Screen]
    let templates: any AdaptyUISchemaTemplateSystem
    let scripts: [String]
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
    private enum CodingKeys: String, CodingKey {
        case formatVersion = "format"
        case legacyTemplateId = "template_id"

        case assets
        case localizations
        case defaultLocalId = "default_localization"
        case templates
        case legacyScreens = "styles"
        case screens
        case navigators
        case script
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        formatVersion = try container.decode(Version.self, forKey: .formatVersion)

        var configuration = DecodingConfiguration(isLegacy: !formatVersion.isNotLegacyVersion)

        if configuration.isLegacy {
            configuration.legacyTemplateId = try container.decode(String.self, forKey: .legacyTemplateId)
        }

        assets = try (container.decodeIfPresent(AssetsCollection.self, forKey: .assets))?.value ?? [:]

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

        let screenKey: CodingKeys =
            if !container.contains(.screens), configuration.isLegacy {
                .legacyScreens
            } else {
                .screens
            }

        let screensCollection = try container.decode(
            ScreensCollection.self,
            forKey: screenKey,
            configuration: configuration
        )

        screens = screensCollection.screens

        if configuration.isLegacy {
            navigators = screensCollection.legacyGeneratedNavigators ?? [:]
        } else {
            navigators = try container.decodeIfPresent(
                NavigatorsCollection.self,
                forKey: .navigators,
                configuration: configuration
            )?.navigators ?? [:]
        }

        let templatesCollection = try container.decodeIfPresent(
            TemplatesCollection.self,
            forKey: .templates,
            configuration: configuration
        )

        templates = try Schema.createTemplateSystem(
            formatVersion: formatVersion,
            templatesCollection: templatesCollection,
            navigators: navigators,
            screens: screens
        )

        scripts =
            if configuration.isLegacy {
                try decoder.legacyGenerateScript(collector: configuration.collector)
            } else {
                try (container.decodeIfPresent(String.self, forKey: .script)).map { [$0] } ?? []
            }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(formatVersion, forKey: .formatVersion)
        try container.encode(AssetsCollection(value: assets), forKey: .assets)
        try container.encode(Array(localizations.values), forKey: .localizations)
        try container.encodeIfPresent(defaultLocalization?.id, forKey: .defaultLocalId)
        try container.encode(screens, forKey: .screens)
    }
}

private enum LegacyCodingKeys: String, CodingKey {
    case products
    case selected
}

private extension Decoder {
    func legacyGenerateScript(collector: AdaptyUISchema.DecodingCollector) throws -> [String] {
        let container = try container(keyedBy: LegacyCodingKeys.self)

        var scripts = [String]()

        if container.contains(.products) {
            let container = try container.nestedContainer(keyedBy: LegacyCodingKeys.self, forKey: .products)
            if let selected = try? container.decodeIfPresent(String.self, forKey: .selected) {
                scripts += [Schema.LegacyScripts.legacySelectProductScript(productId: selected)]
            } else {
                let selectedProducts = try container.decode([String: String].self, forKey: .selected)
                scripts += selectedProducts.map { groupId, productId in
                    Schema.LegacyScripts.legacySelectProductScript(groupId: groupId, productId: productId)
                }
            }
        }

        for section in collector.legacySectionsState {
            scripts += [Schema.LegacyScripts.legacySelectSectionScript(sectionId: section.key, index: section.value)]
        }

        return [Schema.LegacyScripts.actions] + scripts + [Schema.LegacyScripts.legacyOpenDefaultScreen()]
    }
}

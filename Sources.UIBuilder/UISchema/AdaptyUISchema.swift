//
//  AdaptyUISchema.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

@usableFromInline
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

extension AdaptyUISchema: Decodable {
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
        case scripts
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
        } else if let navigatorCollection = try container.decodeIfExist(
            NavigatorsCollection.self,
            forKey: .navigators,
            configuration: configuration
        ) {
            navigators = navigatorCollection.navigators
        } else {
            let navigatorCollection = NavigatorsCollection()
            navigators = navigatorCollection.navigators
        }

        let templatesCollection = try container.decodeIfExist(
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
                try decoder.decodeScript(configuration: configuration)
            }
    }
}

private enum ScriptCodingKeys: String, CodingKey {
    case scripts
    case type
    case content
    case format
}

private extension Decoder {
    func decodeScript(configuration _: AdaptyUISchema.DecodingConfiguration) throws -> [String] {
        let container = try container(keyedBy: ScriptCodingKeys.self)
        guard container.contains(.scripts) else {
            return []
        }
        var scripts = try container.nestedUnkeyedContainer(forKey: .scripts)

        while !scripts.isAtEnd {
            let itemContainer = try scripts.nestedContainer(keyedBy: ScriptCodingKeys.self)
            if let value = try itemContainer.decodeIfPresent(String.self, forKey: .type) {
                guard value == "js" else { continue }
            }
            let content = try itemContainer.decode(String.self, forKey: .content)
            return [content]
        }

        return []
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

        if container.exist(.products) {
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

        scripts.append(contentsOf: collector.legacyTimers.values)

        return [Schema.LegacyScripts.actions] + scripts + [Schema.LegacyScripts.legacyOpenDefaultScreen()]
    }
}


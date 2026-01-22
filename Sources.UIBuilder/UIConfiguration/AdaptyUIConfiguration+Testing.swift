//
//  AdaptyUIConfiguration+Testing.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.05.2024
//

import Foundation

public enum AdaptyUIExampleContent {
    case screen(name: String, value: String)
    case element(name: String, value: String, templateId: String)
}

package extension AdaptyUIConfiguration {
    static func create(
        assets: String,
        localization: String,
        templates templatesCollection: String?,
        contents: [AdaptyUIExampleContent],
        script: String?,
        startScreenName: String
    ) throws -> Self {
        let formatVersion = AdaptyUISchema.formatVersion
        let configuration = Schema.DecodingConfiguration(
            isLegacy: !formatVersion.isNotLegacyVersion,
            legacyTemplateId: nil
        )
        let jsonDecoder = JSONDecoder()

        let dataAssets = assets.data(using: .utf8) ?? Data()
        let dataLocalization = localization.data(using: .utf8) ?? Data()

        let assets = try jsonDecoder.decode(Schema.AssetsContainer.self, from: dataAssets)

        let localiation = try jsonDecoder.decode(Schema.Localization.self, from: dataLocalization)

        let screensArr: [(String, Schema.Screen)] = try contents.map { content in
            switch content {
            case let .screen(name, value):
                let contentData = value.data(using: .utf8) ?? Data()
                return try (name, jsonDecoder.decode(Schema.Screen.self, from: contentData, with: configuration))
            case let .element(name, value, templateId):
                let contentData = value.data(using: .utf8) ?? Data()
                let element = try jsonDecoder.decode(Schema.Element.self, from: contentData, with: configuration)

                return (name, Schema.Screen(
                    templateId: templateId,
                    background: nil,
                    cover: nil,
                    content: element,
                    footer: nil,
                    overlay: nil
                ))
            }
        }

        let screens = Dictionary(screensArr) { first, _ in first }

        let templatesCollection = try templatesCollection.map { value in
            let data = value.data(using: .utf8) ?? Data()
            return try jsonDecoder.decode(Schema.TemplatesCollection.self, from: data, with: configuration)
        }

        let templates = try Schema.createTemplates(
            formatVersion: formatVersion,
            templatesCollection: templatesCollection,
            screens: screens
        )

        let schema = AdaptyUISchema(
            formatVersion: formatVersion,
            assets: assets.value,
            localizations: [localiation.id: localiation],
            defaultLocalization: localiation,
            screens: screens,
            templates: templates,
            scripts: (script.map { [$0] } ?? []) + [Schema.LegacyScripts.legacyOpenScreen(screenId: startScreenName)]
        )

        return try schema.extractUIConfiguration(withLocaleId: localiation.id)
    }
}

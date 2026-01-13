//
//  AdaptyUIConfiguration+Testing.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.05.2024
//

import Foundation

package extension AdaptyUIConfiguration {
    static func create(
        templateId: String,
        assets: String,
        localization: String,
        templates templatesCollection: String?,
        content: String,
        script: String?
    ) throws -> Self {
        let formatVersion = AdaptyUISchema.formatVersion
        let configuration = Schema.DecodingConfiguration(isLegacy: !formatVersion.isNotLegacyVersion, legacyTemplateId: templateId)
        let jsonDecoder = JSONDecoder()

        let dataContent = content.data(using: .utf8) ?? Data()
        let dataAssets = assets.data(using: .utf8) ?? Data()
        let dataLocalization = localization.data(using: .utf8) ?? Data()

        let assets = try jsonDecoder.decode(Schema.AssetsContainer.self, from: dataAssets)

        let localiation = try jsonDecoder.decode(Schema.Localization.self, from: dataLocalization)

        let screen =
            if let element = try? jsonDecoder.decode(Schema.Element.self, from: dataContent, with: configuration) {
                Schema.Screen(
                    templateId: templateId,
                    background: .assetId("$black"),
                    cover: nil,
                    content: element,
                    footer: nil,
                    overlay: nil
                )
            } else {
                try jsonDecoder.decode(Schema.Screen.self, from: dataContent, with: configuration)
            }

        let screenMainName = "main"
        let screens = [screenMainName: screen]

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
            scripts: script.map { [$0] } ?? [] + [Schema.LegacyScripts.legacyOpenScreen(screenId: screenMainName)]
        )

        return try schema.extractUIConfiguration(withLocaleId: localiation.id)
    }
}

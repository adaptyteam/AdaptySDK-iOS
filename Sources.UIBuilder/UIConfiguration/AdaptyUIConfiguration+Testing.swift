//
//  AdaptyUIConfiguration+Testing.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.05.2024
//

import Foundation

#if DEBUG
package extension AdaptyUIConfiguration {
    static func create(
        formatVersion: AdaptyUISchema.Version = AdaptyUISchema.formatVersion,
        templateId: String = "transparent",
        locale: LocaleId = AdaptyUISchema.defaultLocaleId,
        isRightToLeft: Bool = false,
        images: [String] = [],
        colors: [String: Filling] = [:],
        strings: [String: [String]] = [:],
        templatesCollection: String? = nil,
        content: String,
        selectedProducts: [String: String] = [:]
    ) throws -> Self {
        let configuration = Schema.DecodingConfiguration(isLegacy: !formatVersion.isNotLegacyVersion)

        let colors = colors
            .mapValues { Schema.Asset.filling($0) }

        let assets = Dictionary(
            images.map { ($0, Schema.Asset.image(
                .url(
                    customId: $0,
                    URL(string: "https://unknown.image.com")!,
                    previewRaster: nil
                )
            )) }
        ) { current, _ in current }
            .merging(colors) { current, _ in current }

        let jsonDecoder = JSONDecoder()

        let dataContent = content.data(using: .utf8) ?? Data()
        let screen =
            if let element = try? jsonDecoder.decode(Schema.Element.self, from: dataContent, with: configuration) {
                Schema.Screen(
                    backgroundAssetId: "$black",
                    cover: nil,
                    content: element,
                    footer: nil,
                    overlay: nil,
                    selectedAdaptyProductId: nil
                )
            } else {
                try jsonDecoder.decode(Schema.Screen.self, from: dataContent, with: configuration)
            }

        let scrrens = ["default": screen]

        let templatesCollection = try templatesCollection.map { value in
            let data = value.data(using: .utf8) ?? Data()
            return try jsonDecoder.decode(Schema.TemplatesCollection.self, from: data, with: configuration)
        }

        let templates = try Schema.createTemplates(
            formatVersion: formatVersion,
            templatesCollection: templatesCollection,
            screens: scrrens
        )

        let schema = AdaptyUISchema(
            formatVersion: formatVersion,
            templateId: templateId,
            templateRevision: 0,
            assets: assets,
            localizations: [locale: .init(
                id: locale,
                isRightToLeft: isRightToLeft,
                strings: strings.mapValues { items in
                    .init(value: .init(items: items.map {
                        var v = $0
                        return if v.remove(at: v.startIndex) == "#" {
                            .tag(v, nil)
                        } else {
                            .text($0, nil)
                        }
                    }), fallback: nil)
                },
                assets: nil
            )],
            defaultLocalization: nil,
            defaultScreen: screen,
            screens: scrrens,
            templates: templates,
            selectedProducts: selectedProducts
        )

        return try schema.extractUIConfiguration(withLocaleId: locale)
    }
}
#endif

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
        templateId: String = "transparent",
        locale: LocaleId = "en",
        isRightToLeft: Bool = false,
        images: [String] = [],
        colors: [String: Filling] = [:],
        strings: [String: [String]] = [:],
        content: String,
        selectedProducts: [String: String] = [:]
    ) throws -> Self {
        let colors = colors
            .mapValues { AdaptyUISchema.Asset.filling($0) }

        let assets = Dictionary(
            images.map { ($0, AdaptyUISchema.Asset.image(
                .url(
                    customId: $0,
                    URL(string: "https://unknown.image.com")!,
                    previewRaster: nil
                )
            )) }
        ) { current, _ in current }
            .merging(colors) { current, _ in current }

        let data = content.data(using: .utf8) ?? Data()
        let jsonDecoder = JSONDecoder()
        let screen =
            if let element = try? jsonDecoder.decode(AdaptyUISchema.Element.self, from: data) {
                AdaptyUISchema.Screen(
                    backgroundAssetId: "$black",
                    cover: nil,
                    content: element,
                    footer: nil,
                    overlay: nil,
                    selectedAdaptyProductId: nil
                )
            } else {
                try jsonDecoder.decode(AdaptyUISchema.Screen.self, from: data)
            }

        let schema = try AdaptyUISchema(
            formatVersion: AdaptyUISchema.formatVersion,
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
            screens: [:],
            referencedElements: [String: AdaptyUISchema.Element](screen.referencedElements, uniquingKeysWith: { _, _ in
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Duplicate element_id"))
            }),
            selectedProducts: selectedProducts
        )

        return try schema.extractUIConfiguration(
            id: UUID().uuidString,
            withLocaleId: locale
        )
    }
}

#endif

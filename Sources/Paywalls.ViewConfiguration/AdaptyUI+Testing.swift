//
//  AdaptyUI+Testing.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.05.2024
//

import Foundation

#if DEBUG

    package extension AdaptyUI.LocalizedViewConfiguration {
        static func create(
            templateId: String = "transparent",
            locale: String = "en",
            isRightToLeft: Bool = false,
            images: [String] = [],
            colors: [String: AdaptyUI.Filling] = [:],
            strings: [String: [String]] = [:],
            content: String,
            selectedProducts: [String: String] = [:]
        ) throws -> Self {
            let locale = AdaptyLocale(id: locale)

            let colors = colors
                .mapValues { AdaptyUI.ViewConfiguration.Asset.filling($0) }

            let assets = Dictionary(
                images.map { ($0, AdaptyUI.ViewConfiguration.Asset.image(.resources($0))) }
            ) { current, _ in current }
                .merging(colors) { current, _ in current }

            let data = content.data(using: .utf8) ?? Data()
            let jsonDecoder = JSONDecoder()
            Backend.configure(jsonDecoder: jsonDecoder)
            let screen =
                if let element = try? jsonDecoder.decode(AdaptyUI.ViewConfiguration.Element.self, from: data) {
                    AdaptyUI.ViewConfiguration.Screen(
                        backgroundAssetId: "$black",
                        cover: nil,
                        content: element,
                        footer: nil,
                        overlay: nil,
                        selectedAdaptyProductId: nil
                    )
                } else {
                    try jsonDecoder.decode(AdaptyUI.ViewConfiguration.Screen.self, from: data)
                }

            return try AdaptyUI.ViewConfiguration(
                id: UUID().uuidString,
                templateId: templateId,
                templateRevision: 0,
                assets: assets,
                responseLocale: locale,
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
                referencedElemnts: [String: AdaptyUI.ViewConfiguration.Element](screen.referencedElemnts, uniquingKeysWith: { _, _ in
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Duplicate element_id"))
                }),
                selectedProducts: selectedProducts
            ).extractLocale()
        }
    }

#endif

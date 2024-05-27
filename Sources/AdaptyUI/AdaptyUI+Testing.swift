//
//  File.swift
//
//
//  Created by Aleksei Valiano on 16.05.2024
//
//

import Foundation

package extension AdaptyUI.LocalizedViewConfiguration {
    static func create(
        templateId: String = "transparent",
        locale: String = "en",
        isRightToLeft: Bool = false,
        images: [String] = [],
        colors: [String: String] = [:],
        strings: [String: String] = [:],
        content: String
    ) throws -> Self {
        let locale = AdaptyLocale(id: locale)

        let strings = strings.merging([
            "$short": "Article.",
            "$medium": "Article nor prepare chicken you him now.",
            "$long": "Article nor prepare chicken you him now. Shy merits say advice ten before lovers innate add. ",
        ]) { current, _ in current }

        let colors = try colors
            .mapValues { try AdaptyUI.ViewConfiguration.Asset.filling(.color(.init(hex: $0))) }
            .merging([
                "$black": .filling(.color(AdaptyUI.Color.black)),
                "$white": .filling(.color(AdaptyUI.Color(data: 0xFFFFFFFF))),
                "$red": .filling(.color(AdaptyUI.Color(data: 0xFF0000FF))),
                "$green": .filling(.color(AdaptyUI.Color(data: 0x00FF00FF))),
                "$blue": .filling(.color(AdaptyUI.Color(data: 0x0000FFFF))),
                "$light": .filling(.color(AdaptyUI.Color(data: 0xF4D13BFF))),
                "$font": .font(AdaptyUI.Font.default),
                "$red_to_transparent_top_to_bottom": .filling(.colorGradient(.create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0xFF000099), p: 0.0),
                        .create(color: .create(data: 0xFF000000), p: 1.0),
                    ]
                ))),
                "$blue_to_transparent_top_to_bottom": .filling(.colorGradient(.create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0x0000FF99), p: 0.0),
                        .create(color: .create(data: 0x0000FF00), p: 1.0),
                    ]
                ))),
                "$green_to_transparent_top_to_bottom": .filling(.colorGradient(.create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0x00FF0099), p: 0.0),
                        .create(color: .create(data: 0x00FF0000), p: 1.0),
                    ]
                ))),
            ]) { current, _ in current }

        let assets = Dictionary(
            images.map { ($0, AdaptyUI.ViewConfiguration.Asset.filling(.image(.resorces($0)))) }
        ) { current, _ in current }
            .merging(colors) { current, _ in current }

        let data = content.data(using: .utf8) ?? Data()
        let decoder = JSONDecoder()
        Backend.configure(decoder: decoder)
        let screen =
            if let element = try? decoder.decode(AdaptyUI.ViewConfiguration.Element.self, from: data) {
                AdaptyUI.ViewConfiguration.Screen(
                    backgroundAssetId: "$black",
                    cover: nil,
                    content: element,
                    footer: nil,
                    overlay: nil
                )
            } else {
                try decoder.decode(AdaptyUI.ViewConfiguration.Screen.self, from: data)
            }

        return AdaptyUI.ViewConfiguration(
            id: UUID().uuidString,
            templateId: templateId,
            templateRevision: 0,
            assets: assets,
            responseLocale: locale,
            localizations: [locale: .init(
                id: locale,
                isRightToLeft: isRightToLeft,
                strings: strings.mapValues {
                    .init(value: .init(items: [.text($0, nil)]), fallback: nil)
                },
                assets: nil
            )],
            defaultLocalization: nil,
            defaultScreen: screen,
            screens: [:]
        ).extractLocale()
    }
}

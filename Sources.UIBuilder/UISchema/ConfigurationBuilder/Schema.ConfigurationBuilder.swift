//
//  Schema.ConfigurationBuilder.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension Schema {
    final class ConfigurationBuilder: @unchecked Sendable {
        let id = UUID()
        let configuarationId: String
        let localeId: LocaleId
        let isRightToLeft: Bool
        let assets: [String: Asset]
        let strings: [String: VC.RichText]

        let source: AdaptyUISchema
        var templateIds = Set<String>()

        init(id: String, source: AdaptyUISchema, withLocaleId localeId: LocaleId) {
            let localization = source.localization(by: localeId)

            var assets = source.assets
            if let other = localization?.assets {
                assets = assets.merging(other, uniquingKeysWith: { _, other in other })
            }

            self.configuarationId = id
            self.source = source
            self.localeId = localization?.id ?? localeId
            self.isRightToLeft = localization?.isRightToLeft ?? false
            self.assets = assets
            self.strings = localization?.strings?.mapValues {
                VC.RichText(
                    items: $0.value.items,
                    fallback: $0.fallback?.items
                )
            } ?? [:]
        }
    }
}

extension Schema.ConfigurationBuilder: Hashable {
    static func == (lhs: Schema.ConfigurationBuilder, rhs: Schema.ConfigurationBuilder) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Schema.ConfigurationBuilder {
    func localize() throws -> AdaptyUIConfiguration {
        
        templateIds.removeAll()
        return try .init(
            id: configuarationId,
            locale: localeId,
            isRightToLeft: isRightToLeft,
            assets: assets,
            strings: strings,
            navigators: source.navigators.mapValues(convertNavigator),
            screens: source.screens.mapValues(convertScreen),
            scripts: source.scripts
        )
    }
}


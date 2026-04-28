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
        let localizationId: LocaleId
        let locale: Locale
        let isRightToLeft: Bool
        let assets: [String: Asset]
        let strings: [String: VC.RichText]

        let source: AdaptyUISchema
        var templateIds = Set<String>()

        init(id: String, source: AdaptyUISchema, withLocaleId localizationId: LocaleId) {
            let localization = source.localization(by: localizationId)

            var assets = source.assets
            if let other = localization?.assets {
                assets = assets.merging(other, uniquingKeysWith: { _, other in other })
            }

            configuarationId = id
            self.source = source
            isRightToLeft = localization?.isRightToLeft ?? false
            self.assets = assets
            strings = localization?.strings?.mapValues {
                VC.RichText(
                    items: $0.value.items,
                    fallback: $0.fallback?.items
                )
            } ?? [:]

            self.localizationId = localization?.id ?? localizationId
            locale = if let identifier = localization?.localeIdentificator {
                Locale(identifier: identifier)
            } else {
                Locale.current
            }
        }
    }
}

extension Schema.ConfigurationBuilder {
    func localize(envoriment: VC.EnvironmentConstants) throws -> AdaptyUIConfiguration {
        templateIds.removeAll()
        return try .init(
            id: configuarationId,
            localizationId: localizationId,
            locale: locale,
            isRightToLeft: isRightToLeft,
            environment: envoriment,
            assets: assets,
            strings: strings,
            navigators: source.navigators.mapValues(convertNavigator),
            screens: source.screens.mapValues(convertScreen),
            scripts: source.scripts
        )
    }
}


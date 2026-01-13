//
//  AdaptyUISchema.Localizer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUISchema {
    final class Localizer: @unchecked Sendable {
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

extension AdaptyUISchema.Localizer: Hashable {
    static func == (lhs: Schema.Localizer, rhs: Schema.Localizer) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AdaptyUISchema.Localizer {
    func localize() throws -> AdaptyUIConfiguration {
        templateIds.removeAll()
        return try .init(
            id: configuarationId,
            locale: localeId,
            isRightToLeft: isRightToLeft,
            assets: assets,
            strings: strings,
            screens: source.screens.mapValues(screen),
            scripts: source.scripts
        )
    }
}

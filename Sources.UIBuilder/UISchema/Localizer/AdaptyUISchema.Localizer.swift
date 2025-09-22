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
        let localization: Localization?
        let source: AdaptyUISchema
        let localeId: LocaleId
        var elementIds = Set<String>()

        init(id: String, source: AdaptyUISchema, withLocaleId localeId: LocaleId) {
            self.configuarationId = id
            self.source = source
            self.localization = source.localization(by: localeId)
            self.localeId = self.localization?.id ?? localeId
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
        elementIds.removeAll()
        return try .init(
            id: configuarationId,
            locale: localeId,
            isRightToLeft: localization?.isRightToLeft ?? false,
            templateId: source.templateId,
            screen: screen(source.defaultScreen),
            bottomSheets: source.screens.mapValues(bottomSheet),
            templateRevision: source.templateRevision,
            selectedProducts: source.selectedProducts
        )
    }
}

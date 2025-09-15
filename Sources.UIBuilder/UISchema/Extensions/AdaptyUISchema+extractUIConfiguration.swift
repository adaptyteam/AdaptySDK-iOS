//
//  AdaptyUISchema+extractUIConfiguration.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.09.2025.
//

extension AdaptyUISchema {
    func extractUIConfiguration() throws -> AdaptyUIConfiguration {
        try extractUIConfiguration(withLocaleId: responseLocaleId)
    }

    func extractUIConfiguration(withLocaleId localeId: LocaleId) throws -> AdaptyUIConfiguration {
        try Localizer(source: self, withLocaleId: localeId).localize()
    }
}

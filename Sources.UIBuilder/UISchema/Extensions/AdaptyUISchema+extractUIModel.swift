//
//  AdaptyUISchema+extractModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.09.2025.
//

extension AdaptyUISchema {
    func extractUIModel() throws -> AdaptyViewConfiguration {
        try extractUIModel(withLocaleId: responseLocaleId)
    }

    func extractUIModel(withLocaleId localeId: LocaleId) throws -> AdaptyViewConfiguration {
        try Localizer(source: self, withLocaleId: localeId).localize()
    }
}

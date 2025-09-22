//
//  AdaptyUISchema+extractUIConfiguration.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.09.2025.
//

package extension AdaptyUISchema {
    func extractUIConfiguration(id: String, withLocaleId localeId: LocaleId) throws -> AdaptyUIConfiguration {
        try Localizer(id: id, source: self, withLocaleId: localeId).localize()
    }
}

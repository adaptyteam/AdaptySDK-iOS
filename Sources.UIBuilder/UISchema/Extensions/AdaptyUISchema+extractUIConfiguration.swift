//
//  AdaptyUISchema+extractUIConfiguration.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.09.2025.
//

import Foundation

package extension AdaptyUISchema {
    func extractUIConfiguration(id: String, withLocaleId localeId: LocaleId? = nil) throws -> AdaptyUIConfiguration {
        let id = id
        let localeId = localeId ?? defaultLocalization?.id ?? AdaptyUISchema.defaultLocaleId
        return try ConfigurationBuilder(id: id, source: self, withLocaleId: localeId).localize()
    }
}

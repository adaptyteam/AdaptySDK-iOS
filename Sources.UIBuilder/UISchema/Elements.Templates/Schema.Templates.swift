//
//  Schema.Templates.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 02.12.2025.
//

import Foundation

protocol AdaptyUISchemaTemplates: Sendable, Hashable {}

extension Schema {
    typealias Templates = AdaptyUISchemaTemplates
}

extension Schema {
    static func createTemplates(
        formatVersion: Schema.Version,
        templatesCollection: Schema.TemplatesCollection?,
        navigators: [NavigatorIdentifier: Navigator],
        screens: [String: Schema.Screen]
    ) throws -> any AdaptyUISchemaTemplates {
        if formatVersion.isNotLegacyVersion {
            try Schema.RichTemplates.create(templatesCollection: templatesCollection, navigators: navigators, screens: screens)
        } else {
            try Schema.LegacyTemplates.create(screens: screens)
        }
    }
}

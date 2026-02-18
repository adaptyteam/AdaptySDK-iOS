//
//  Schema.TemplateSystem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 02.12.2025.
//

import Foundation

protocol AdaptyUISchemaTemplateSystem: Sendable, Hashable {}

extension AdaptyUISchema {
    typealias TemplateSystem = AdaptyUISchemaTemplateSystem

    static func createTemplateSystem(
        formatVersion: Schema.Version,
        templatesCollection: Schema.TemplatesCollection?,
        navigators: [NavigatorIdentifier: Navigator],
        screens: [String: Schema.Screen]
    ) throws -> any TemplateSystem {
        if formatVersion.isNotLegacyVersion {
            try Schema.RichTemplateSystem.create(templatesCollection: templatesCollection)
        } else {
            try Schema.LegacyTemplateSystem.create(screens: screens, navigators: navigators)
        }
    }
}

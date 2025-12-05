//
//  Schema.RichTemplates.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 02.12.2025.
//

import Foundation

extension Schema {
    struct RichTemplates: Templates {
        let templates: [String: Template]
    }
}

extension Schema.RichTemplates {
    static func create(
        templatesCollection: Schema.TemplatesCollection?,
        screens: [String: Schema.Screen]
    ) throws -> Self {
        .init(
            templates: templatesCollection?.values ?? [:]
        )
    }
}

extension Schema.Localizer {
    func templateInstance(_ id: String) throws -> VC.Element {
        guard !self.templateIds.contains(id) else {
            throw Schema.Error.elementsTreeCycle(id)
        }
        guard let templates = source.templates as? Schema.RichTemplates else {
            throw Schema.Error.notFoundTemplate(id)
        }
        guard let instance = templates.templates[id] else {
            throw Schema.Error.notFoundTemplate(id)
        }
        templateIds.insert(id)
        let result: VC.Element
        do {
            result = try element(instance.content)
            templateIds.remove(id)
        } catch {
            templateIds.remove(id)
            throw error
        }
        return result
    }
}

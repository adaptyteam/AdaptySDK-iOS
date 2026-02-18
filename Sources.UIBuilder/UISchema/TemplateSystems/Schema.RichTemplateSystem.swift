//
//  Schema.RichTemplateSystem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 02.12.2025.
//

import Foundation

extension AdaptyUISchema {
    struct RichTemplateSystem: TemplateSystem {
        let templates: [String: Template]
    }
}

extension AdaptyUISchema.RichTemplateSystem {
    static func create(
        templatesCollection: Schema.TemplatesCollection?
    ) throws -> Self {
        .init(
            templates: templatesCollection?.values ?? [:]
        )
    }
}

extension Schema.Localizer {
    func templateInstance(_ instance: Schema.TemplateInstance) throws -> VC.Element {
        let id = instance.type
        guard !self.templateIds.contains(id) else {
            throw Schema.Error.elementsTreeCycle(id)
        }
        guard let templates = source.templates as? Schema.RichTemplateSystem else {
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

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
    func planTemplateInstance(
        _ instance: Schema.TemplateInstance,
        in workStack: inout [WorkItem]
    ) throws {
        let id = instance.type
        guard !templateIds.contains(id) else {
            throw Schema.Error.elementsTreeCycle(id)
        }
        guard let templates = source.templates as? Schema.RichTemplateSystem else {
            throw Schema.Error.notFoundTemplate(id)
        }
        guard let instance = templates.templates[id] else {
            throw Schema.Error.notFoundTemplate(id)
        }
        templateIds.insert(id)
        workStack.append(.leaveTemplate(id))
        workStack.append(.planElement(instance.content))
    }
}

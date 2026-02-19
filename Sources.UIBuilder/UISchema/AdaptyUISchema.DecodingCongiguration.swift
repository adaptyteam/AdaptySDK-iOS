//
//  AdaptyUISchema.DecodingCongiguration.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.02.2026.
//

import Foundation

package extension AdaptyUISchema {
    struct DecodingConfiguration {
        let isLegacy: Bool
        var insideTemplateId: String?
        var insideScreenId: String?
        var insideNavigatorId: String?
        var legacyTemplateId: String?
        nonisolated(unsafe) let legacyCollector: LegacyCollector = .init()
    }

    final class LegacyCollector {
        var sections: [String: Int32] = [:]
    }
}

extension AdaptyUISchema.DecodingConfiguration {
    var isNavigator: Bool {
        insideNavigatorId != nil
    }

    var isTemplate: Bool {
        insideTemplateId != nil
    }
}

// # mark legacy

extension AdaptyUISchema.DecodingConfiguration {
    var screenLayoutBehaviourFromLegacy: Schema.Screen.LayoutBehaviour? {
        guard isLegacy else {
            return nil
        }
        guard insideScreenId == "default", let legacyTemplateId else {
            return .default
        }

        guard legacyTemplateId != "basic" else {
            return .hero
        }

        return .init(rawValue: legacyTemplateId) ?? .default
    }
}

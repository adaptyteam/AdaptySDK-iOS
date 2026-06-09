//
//  AdaptyUISchema.DecodingCongiguration.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.02.2026.
//

import Foundation

extension AdaptyUISchema {
    public struct DecodingConfiguration: Sendable {
        let device: DeviceKind

        public init(device: DeviceKind) {
            self.device = device
        }
    }

    struct InternalDecodingConfiguration {
        let device: DeviceKind
        let isLegacy: Bool
        var insideTemplateId: String?
        var insideScreenId: String?
        var insideNavigatorId: String?
        var legacyTemplateId: String?
        nonisolated(unsafe) let collector: DecodingCollector = .init()

        init(from: DecodingConfiguration, isLegacy: Bool) {
            self.device = from.device
            self.isLegacy = isLegacy
        }
    }

    final class DecodingCollector {
        var legacySectionsState: [String: Int32] = [:]
        var legacyTimers: [String: String] = [:]
    }
}

extension AdaptyUISchema.InternalDecodingConfiguration {
    var isNavigator: Bool {
        insideNavigatorId != nil
    }

    var isTemplate: Bool {
        insideTemplateId != nil
    }
}

// # mark legacy

extension AdaptyUISchema.InternalDecodingConfiguration {
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


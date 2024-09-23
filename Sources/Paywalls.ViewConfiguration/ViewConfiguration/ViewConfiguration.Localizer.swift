//
//  ViewConfiguration.Localizer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    final class Localizer: @unchecked Sendable {
        let id = UUID()
        let localization: Localization?
        let source: AdaptyUI.ViewConfiguration
        let locale: AdaptyLocale
        var elementIds = Set<String>()

        init(source: AdaptyUI.ViewConfiguration, withLocale: AdaptyLocale) {
            self.source = source
            self.localization = source.getLocalization(withLocale)
            self.locale = self.localization?.id ?? withLocale
        }
    }
}

extension AdaptyUI.ViewConfiguration.Localizer: Hashable {
    static func == (lhs: AdaptyUI.ViewConfiguration.Localizer, rhs: AdaptyUI.ViewConfiguration.Localizer) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func localize() throws -> AdaptyUI.LocalizedViewConfiguration {
        elementIds.removeAll()
        return try .init(
            id: source.id,
            locale: locale.id,
            isRightToLeft: localization?.isRightToLeft ?? false,
            templateId: source.templateId,
            screen: screen(source.defaultScreen),
            bottomSheets: source.screens.mapValues(bottomSheet),
            templateRevision: source.templateRevision,
            selectedProducts: source.selectedProducts
        )
    }
}

extension AdaptyUI {
    package enum LocalizerError: Swift.Error {
        case notFoundAsset(String)
        case wrongTypeAsset(String, expected: String)

        case unknownReference(String)
        case referenceCycle(String)
    }
}

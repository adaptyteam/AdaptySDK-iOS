//
//  ViewConfiguration.Localizer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    final class Localizer: @unchecked Sendable {
        let id = UUID()
        let localization: Localization?
        let source: AdaptyUICore.ViewConfiguration
        let locale: AdaptyLocale
        var elementIds = Set<String>()

        init(source: AdaptyUICore.ViewConfiguration, withLocale: AdaptyLocale) {
            self.source = source
            self.localization = source.getLocalization(withLocale)
            self.locale = self.localization?.id ?? withLocale
        }
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer: Hashable {
    static func == (lhs: AdaptyUICore.ViewConfiguration.Localizer, rhs: AdaptyUICore.ViewConfiguration.Localizer) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func localize() throws -> AdaptyUICore.LocalizedViewConfiguration {
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

extension AdaptyUICore {
    package enum LocalizerError: Swift.Error {
        case notFoundAsset(String)
        case wrongTypeAsset(String)
        case unknownReference(String)
        case referenceCycle(String)
    }
}

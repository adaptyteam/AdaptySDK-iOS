//
//  AdaptyViewSource.Localizer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyViewSource {
    final class Localizer: @unchecked Sendable {
        let id = UUID()
        let localization: Localization?
        let source: AdaptyViewSource
        let locale: AdaptyLocale
        var elementIds = Set<String>()

        init(source: AdaptyViewSource, withLocale: AdaptyLocale) {
            self.source = source
            self.localization = source.getLocalization(withLocale)
            self.locale = self.localization?.id ?? withLocale
        }
    }
}

extension AdaptyViewSource.Localizer: Hashable {
    static func == (lhs: AdaptyViewSource.Localizer, rhs: AdaptyViewSource.Localizer) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AdaptyViewSource.Localizer {
    func localize() throws -> AdaptyViewConfiguration {
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

package enum AdaptyViewLocalizerError: Swift.Error {
    case notFoundAsset(String)
    case wrongTypeAsset(String)
    case unknownReference(String)
    case referenceCycle(String)
}

//
//  ViewConfiguration.Localizer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    class Localizer {
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

extension AdaptyUI.ViewConfiguration.Localizer {
    func localize() throws -> AdaptyUI.LocalizedViewConfiguration {
        try .init(
            id: source.id,
            locale: locale.id,
            isRightToLeft: localization?.isRightToLeft ?? false,
            templateId: source.templateId,
            screen: screen(source.defaultScreen),
            bottomSheets: source.screens.mapValues(bottomSheet),
            templateRevision: source.templateRevision
        )
    }
}

extension AdaptyUI {
    package enum LocalizerError: Swift.Error {
        case unknownReference(String)
        case referenceCycle(String)
    }
}

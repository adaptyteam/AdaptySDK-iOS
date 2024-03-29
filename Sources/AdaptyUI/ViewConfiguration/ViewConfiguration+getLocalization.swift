//
//  ViewConfiguration+getLocalization.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 29.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    public func extractLocale(_ locale: String) -> AdaptyUI.LocalizedViewConfiguration {
        Localizer(
            source: self,
            withLocale: AdaptyLocale(id: locale)
        ).localize()
    }

    func getLocalization(_ locale: AdaptyLocale) -> Localization? {
        if let value = localizations[locale] {
            if defaultLocalization?.id == value.id {
                value
            } else {
                value.addDefault(localization: defaultLocalization)
            }
        } else {
            defaultLocalization
        }
    }
}

private extension AdaptyUI.ViewConfiguration.Localization {
    func addDefault(localization: Self?) -> Self {
        guard let localization else { return self }

        var strings = self.strings ?? [:]
        if let other = localization.strings {
            strings = strings.merging(other, uniquingKeysWith: { current, _ in current })
        }

        var assets = self.assets ?? [:]
        if let other = localization.assets {
            assets = assets.merging(other, uniquingKeysWith: { current, _ in current })
        }

        return .init(
            id: id,
            strings: strings.isEmpty ? nil : strings,
            assets: assets.isEmpty ? nil : assets
        )
    }
}
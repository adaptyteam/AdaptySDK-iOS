//
//  AdaptyUISchema+localization.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.03.2024
//

import Foundation

extension AdaptyUISchema {
    func localization(by localeId: LocaleId) -> Localization? {
        if let value = localizations[localeId] {
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

private extension Schema.Localization {
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
            isRightToLeft: isRightToLeft ?? localization.isRightToLeft,
            strings: strings.nonEmptyOrNil,
            assets: assets.nonEmptyOrNil
        )
    }
}

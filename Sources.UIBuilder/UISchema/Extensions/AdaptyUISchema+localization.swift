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
            value.add(defaultLocalization: defaultLocalization)
        } else {
            defaultLocalization
        }
    }
}

private extension Schema.Localization {
    func add(defaultLocalization: Self?) -> Self {
        guard let defaultLocalization, id != defaultLocalization.id else { return self }

        var strings = strings ?? [:]
        if let other = defaultLocalization.strings {
            strings = strings.merging(other, uniquingKeysWith: { current, _ in current })
        }

        var assets = assets ?? [:]
        if let other = defaultLocalization.assets {
            assets = assets.merging(other, uniquingKeysWith: { current, _ in current })
        }

        return .init(
            id: id,
            isRightToLeft: isRightToLeft ?? defaultLocalization.isRightToLeft,
            localeIdentificator: localeIdentificator ?? defaultLocalization.localeIdentificator,
            strings: strings.nonEmptyOrNil,
            assets: assets.nonEmptyOrNil
        )
    }
}


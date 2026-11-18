//
//  AdaptyUISchema+localization.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.03.2024
//

import Foundation

package extension AdaptyUISchema {
    func preferredLocalizations(forPreferences: [LocaleId], strategy: AdaptyUILocalizationStrategy) async -> LocaleId? {
         let resolver = switch strategy {
         case .default where formatVersion.isLegacyVersion: LegacyLocalizationResolver()
         case .default,
              .system: SystemLocalizationResolver()
         case .legacy: LegacyLocalizationResolver()
         case .identity: IdentityLocalizationResolver()
         case let .custom(resolver): resolver
         }

        return await resolver.resolve(
            for: forPreferences,
            from: .init(locales: allLocalIds, defaultLocale: defaultLocalId)
        )
    }
}

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

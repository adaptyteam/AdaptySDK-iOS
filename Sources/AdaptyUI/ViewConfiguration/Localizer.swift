//
//  Localizer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
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

    struct Localizer {
        private let localization: Localization?
        let source: AdaptyUI.ViewConfiguration
        let locale: AdaptyLocale

        init(from: AdaptyUI.ViewConfiguration, withLocale: AdaptyLocale) {
            self.source = from
            self.localization = from.getLocalization(withLocale)
            self.locale = self.localization?.id ?? withLocale
        }

        func assetIfPresent(_ assetId: String?) -> Asset? {
            guard let assetId else { return nil }
            return localization?.assets?[assetId] ?? source.assets[assetId]
        }

        func fillingIfPresent(_ assetId: String?) -> AdaptyUI.Filling? {
            assetIfPresent(assetId)?.asFilling
        }

        func image(_ assetId: String?) -> AdaptyUI.ImageData {
            assetIfPresent(assetId)?.asFilling?.asImage ?? .none
        }

        func font(_ assetId: String?) -> AdaptyUI.Font {
            assetIfPresent(assetId)?.asFont ?? AdaptyUI.Font.default
        }

        func urlIfPresent(_ stringId: String?) -> String? {
            guard let stringId, let item = self.localization?.strings?[stringId] else { return nil }
            return item.value.asString ?? item.fallback?.asString
        }

        func richTextIfPresent(_ stringId: String?) -> AdaptyUI.RichText? {
            guard let stringId, let item = localization?.strings?[stringId] else { return nil }
            return AdaptyUI.RichText(
                items: item.value.convert(self),
                fallback: item.fallback.map { $0.convert(self) }
            )
        }

        func richText(from textBlock: AdaptyUI.ViewConfiguration.TextBlock) -> AdaptyUI.RichText {
            guard let item = localization?.strings?[textBlock.stringId] else { return AdaptyUI.RichText.empty }
            return textBlock.convert(self, item: item)
        }

        func richText(from text: AdaptyUI.ViewConfiguration.OldText) -> AdaptyUI.RichText {
            text.convert(self)
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

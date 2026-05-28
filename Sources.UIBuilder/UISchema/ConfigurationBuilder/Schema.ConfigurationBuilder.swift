//
//  Schema.ConfigurationBuilder.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension Schema {
    final class ConfigurationBuilder: @unchecked Sendable {
        let id = UUID()
        let configuarationId: String
        let localizationId: LocaleId
        let locale: Locale
        let isRightToLeft: Bool
        let assets: [String: VC.Asset]
        let strings: [String: VC.RichText]

        let source: AdaptyUISchema
        var templateIds = Set<String>()

        init(id: String, source: AdaptyUISchema, withLocaleId localizationId: LocaleId) {
            let localization = source.localization(by: localizationId)

            configuarationId = id
            self.source = source
            isRightToLeft = localization?.isRightToLeft ?? false

            assets = Self.convertAssets(source.assets, localization?.assets)

            strings = localization?.strings?.mapValues {
                VC.RichText(
                    items: $0.value.items,
                    fallback: $0.fallback?.items
                )
            } ?? [:]

            self.localizationId = localization?.id ?? localizationId
            locale = if let identifier = localization?.localeIdentificator {
                Locale(identifier: identifier)
            } else {
                Locale.current
            }
        }
    }
}

extension Schema.ConfigurationBuilder {
    fileprivate static func convertAssets(
        _ assets: [Schema.AssetIdentifier: Schema.Asset],
        _ locolizedAssets: [Schema.AssetIdentifier: Schema.Asset]?
    ) -> [VC.AssetIdentifier: VC.Asset] {
        var assets = assets
        if let other = locolizedAssets {
            assets = assets.merging(other, uniquingKeysWith: { _, other in other })
        }

        return assets.reduce(into: [VC.AssetIdentifier: VC.Asset]()) { result, item in
            let (startAssetId, startAsset) = item
            var currentAsset = startAsset
            var visited = Set<Schema.AssetIdentifier>()

            while true {
                switch currentAsset {
                case let .asset(asset):
                    result[startAssetId] = asset
                    return
                case let .unknown(type, fallbackAssetId):
                    guard let fallbackAssetId else {
                        result[startAssetId] = .unknown(type)
                        return
                    }
                    // cycle detection
                    if !visited.insert(fallbackAssetId).inserted {
                        result[startAssetId] = .unknown(type)
                        return
                    }
                    guard let next = assets[fallbackAssetId] else {
                        result[startAssetId] = .unknown(type)
                        return
                    }
                    currentAsset = next
                }
            }
        }
    }

    func localize(envoriment: VC.EnvironmentConstants) throws -> AdaptyUIConfiguration {
        templateIds.removeAll()
        return try .init(
            formatVersion: source.formatVersion,
            id: configuarationId,
            localizationId: localizationId,
            locale: locale,
            isRightToLeft: isRightToLeft,
            environment: envoriment,
            assets: assets,
            strings: strings,
            navigators: source.navigators.mapValues(convertNavigator),
            screens: source.screens.mapValues(convertScreen),
            scripts: source.scripts,
            showPurchaseLoader: source.showPurchaseLoader,
            showRestoreLoader: source.showRestoreLoader
        )
    }
}


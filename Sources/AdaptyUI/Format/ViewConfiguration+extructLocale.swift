//
//  ViewConfiguration+extructLocale.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    public func extructLocale(_ locale: String) -> AdaptyUI.LocalizedViewConfiguration {
        let localization: AdaptyUI.Localization?
        if let value = localizations[locale] {
            if defaultLocalization?.id == value.id {
                localization = value
            } else {
                localization = value.addDefault(localization: defaultLocalization)
            }
        } else {
            localization = defaultLocalization
        }

        func getAsset(_ id: String?) -> AdaptyUI.Asset? {
            guard let id = id else { return nil }
            return localization?.assets?[id] ?? assets[id]
        }

        func getAssetFont(_ id: String?) -> AdaptyUI.Font? {
            guard let asset = getAsset(id) else { return nil }
            switch asset {
            case let .font(value):
                return value
            default:
                return nil
            }
        }

        func getAssetColor(_ id: String?) -> AdaptyUI.Color? {
            guard let asset = getAsset(id) else { return nil }
            switch asset {
            case let .color(value):
                return value
            default:
                return nil
            }
        }

        func getString(_ id: String?) -> String? {
            guard let id = id else { return nil }
            return localization?.strings?[id]
        }

        func convert(_ items: [String: AdaptyUI.ViewItem]?) -> [String: AdaptyUI.LocalizedViewItem]? {
            guard let items = items, !items.isEmpty else { return nil }
            var result = [String: AdaptyUI.LocalizedViewItem]()
            result.reserveCapacity(items.count)
            for item in items {
                switch item.value {
                case let .unknown(value):
                    result[item.key] = .unknown(value)
                case let .asset(id):
                    guard let asset = getAsset(id) else {
                        result[item.key] = .unknown("asset.id: \(id)")
                        break
                    }
                    switch asset {
                    case let .color(value):
                        result[item.key] = .color(value)
                    case let .image(value):
                        result[item.key] = .image(value)
                    case let .unknown(value):
                        result[item.key] = .unknown(value)
                    case .font:
                        result[item.key] = .unknown("unsupport asset {type: font, id: \(id)}")
                    }
                case let .text(value):
                    let font = getAssetFont(value.fontAssetId)
                    result[item.key] = .text(AdaptyUI.Text(
                        value: getString(value.stringId),
                        font: font,
                        size: value.size ?? font?.defaultSize,
                        color: getAssetColor(value.colorAssetId) ?? font?.defaultColor
                    ))
                case let .textRows(value):
                    let font = getAssetFont(value.fontAssetId)
                    let defaultColor = getAssetColor(value.colorAssetId) ?? font?.defaultColor
                    let defaultSize = value.size ?? font?.defaultSize
                    result[item.key] = .textRows(AdaptyUI.TextRows(
                        font: font,
                        rows: value.rows.map({ row in
                            AdaptyUI.TextRow(
                                value: getString(row.stringId),
                                size: row.size ?? defaultSize,
                                color: getAssetColor(row.colorAssetId) ?? defaultColor
                            )
                        })
                    ))
                }
            }
            return result.isEmpty ? nil : result
        }

        var styles = [String: AdaptyUI.LocalizedViewStyle]()
        styles.reserveCapacity(self.styles.count)

        for style in self.styles {
            let value = AdaptyUI.LocalizedViewStyle(
                common: convert(style.value.common),
                custom: convert(style.value.custom)
            )

            if !value.isEmpty {
                styles[style.key] = value
            }
        }

        return AdaptyUI.LocalizedViewConfiguration(
            templateId: templateId,
            locale: localization?.id ?? locale,
            styles: styles,
            isHard: isHard,
            termsUrl: getString(termsUrlId),
            privacyUrl: getString(privacyUrlId),
            version: version
        )
    }
}

extension AdaptyUI.Localization {
    fileprivate func addDefault(localization: Self?) -> Self {
        guard let localization = localization else { return self }

        var strings = self.strings ?? [:]
        if let other = localization.strings {
            strings = strings.merging(other, uniquingKeysWith: { current, _ in current })
        }

        var assets = self.assets ?? [:]
        if let other = localization.assets {
            assets = assets.merging(other, uniquingKeysWith: { current, _ in current })
        }

        return AdaptyUI.Localization(
            id: id,
            strings: strings.isEmpty ? nil : strings,
            assets: assets.isEmpty ? nil : assets
        )
    }
}

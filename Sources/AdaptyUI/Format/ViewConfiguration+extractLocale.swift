//
//  ViewConfiguration+extractLocale.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    public func extractLocale(_ locale: String) -> AdaptyUI.LocalizedViewConfiguration {
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

        func getAssetFilling(_ id: String?) -> AdaptyUI.Filling? {
            guard let asset = getAsset(id) else { return nil }
            switch asset {
            case let .filling(value):
                return value
            default:
                return nil
            }
        }

        func getString(_ id: String?) -> String? {
            guard let id = id else { return nil }
            return localization?.strings?[id]
        }
        func getShapeOrNil(from value: AdaptyUI.ViewItem.Shape?) -> AdaptyUI.Shape? {
            guard let value else { return nil }
            return getShape(from: value)
        }
        func getShape(from value: AdaptyUI.ViewItem.Shape) -> AdaptyUI.Shape {
            AdaptyUI.Shape(
                background: getAssetFilling(value.backgroundAssetId),
                mask: value.mask
            )
        }

        func getButtonActionOrNil(from value: AdaptyUI.ButtonAction?) -> AdaptyUI.ButtonAction? {
            guard let value else { return nil }
            return getButtonAction(from: value)
        }

        func getButtonAction(from value: AdaptyUI.ButtonAction) -> AdaptyUI.ButtonAction {
            guard case let .openUrl(id) = value else { return value }
            return .openUrl(getString(id))
        }

        func getTextOrNil(from value: AdaptyUI.ViewItem.Text?) -> AdaptyUI.Text? {
            guard let value else { return nil }
            return getText(from: value)
        }
        func getText(from value: AdaptyUI.ViewItem.Text) -> AdaptyUI.Text {
            let font = getAssetFont(value.fontAssetId)
            return AdaptyUI.Text(
                value: getString(value.stringId),
                font: font,
                size: value.size ?? font?.defaultSize,
                fill: getAssetFilling(value.fillAssetId) ?? font?.defaultFilling,
                horizontalAlign: value.horizontalAlign ?? font?.defaultHorizontalAlign ?? AdaptyUI.Text.defaultHorizontalAlign
            )
        }

        func convert(_ items: [String: AdaptyUI.ViewItem]?) -> [String: AdaptyUI.LocalizedViewItem] {
            guard let items = items, !items.isEmpty else { return [:] }
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
                    case let .filling(value):
                        result[item.key] = .filling(value)
                    case let .unknown(value):
                        result[item.key] = .unknown(value)
                    case .font:
                        result[item.key] = .unknown("unsupported asset {type: font, id: \(id)}")
                    }
                case let .shape(value):
                    result[item.key] = .shape(getShape(from: value))
                case let .button(value):
                    result[item.key] = .button(AdaptyUI.Button(
                        shape: getShapeOrNil(from: value.shape),
                        title: getTextOrNil(from: value.title),
                        align: value.align ?? AdaptyUI.Button.defaultAlign,
                        action: getButtonActionOrNil(from: value.action)
                    ))
                case let .text(value):
                    result[item.key] = .text(getText(from: value))
                case let .textRows(value):
                    let defaultFont = getAssetFont(value.fontAssetId)
                    let defaultFilling = getAssetFilling(value.fillAssetId)
                    let defaultBullet = getAssetFilling(value.bulletAssetId)?.asImage

                    result[item.key] = .textRows(AdaptyUI.TextRows(
                        rows: value.rows.map({ row in
                            let font = getAssetFont(row.fontAssetId) ?? defaultFont
                            return AdaptyUI.TextRow(
                                font: font,
                                bullet: getAssetFilling(row.bulletAssetId)?.asImage ?? defaultBullet,
                                value: getString(row.stringId),
                                size: row.size ??  value.size ?? font?.defaultSize,
                                fill: getAssetFilling(row.fillAssetId) ?? defaultFilling ?? font?.defaultFilling,
                                horizontalAlign: row.horizontalAlign ?? value.horizontalAlign ?? font?.defaultHorizontalAlign ?? AdaptyUI.TextRow.defaultHorizontalAlign
                            )
                        })
                    ))
                }
            }
            return result.isEmpty ? [:] : result
        }

        var styles = [String: AdaptyUI.LocalizedViewStyle]()
        styles.reserveCapacity(self.styles.count)

        for style in self.styles {
            styles[style.key] = AdaptyUI.LocalizedViewStyle(
                featureBlock: style.value.featuresBlock.map { AdaptyUI.FeaturesBlock(
                    type: $0.type,
                    items: convert($0.items)
                ) },
                productBlock: AdaptyUI.ProductsBlock(
                    type: style.value.productsBlock.type,
                    mainProductIndex: style.value.productsBlock.mainProductIndex,
                    items: convert(style.value.productsBlock.items)
                ),
                footerBlock: style.value.footerBlock.map { AdaptyUI.FooterBlock(
                    items: convert($0.items)
                ) },
                items: convert(style.value.items))
        }

        return AdaptyUI.LocalizedViewConfiguration(
            id: id,
            templateId: templateId,
            locale: localization?.id ?? locale,
            styles: styles,
            isHard: isHard,
            mainImageRelativeHeight: mainImageRelativeHeight,
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

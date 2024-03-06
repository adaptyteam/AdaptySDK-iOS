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
        extractLocale(AdaptyLocale(id: locale))
    }

    func getLocalization(_ locale: AdaptyLocale) -> AdaptyUI.Localization? {
        if let value = localizations[locale] {
            if defaultLocalization?.id == value.id {
                return value
            } else {
                return value.addDefault(localization: defaultLocalization)
            }
        } else {
            return defaultLocalization
        }
    }



    func extractLocale(_ locale: AdaptyLocale) -> AdaptyUI.LocalizedViewConfiguration {
        let localization = getLocalization(locale)

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

        func getString(_ id: String?) -> AdaptyUI.Localization.Item? {
            guard let id = id else { return nil }
            return localization?.strings?[id]
        }
        func getShapeOrNil(from value: AdaptyUI.ViewItem.Shape?) -> AdaptyUI.Shape? {
            guard let value else { return nil }
            return getShape(from: value)
        }
        func getShape(from item: AdaptyUI.ViewItem.Shape) -> AdaptyUI.Shape {
            var border: AdaptyUI.Shape.Border?
            if let filling = getAssetFilling(item.borderAssetId) {
                border = .init(filling: filling, thickness: item.borderThickness ?? AdaptyUI.Shape.Border.defaultThickness)
            }
            return AdaptyUI.Shape(
                background: getAssetFilling(item.backgroundAssetId),
                border: border,
                type: item.type
            )
        }

        func getButtonActionOrNil(from value: AdaptyUI.ButtonAction?) -> AdaptyUI.ButtonAction? {
            guard let value else { return nil }
            return getButtonAction(from: value)
        }

        func getButtonAction(from value: AdaptyUI.ButtonAction) -> AdaptyUI.ButtonAction {
            guard case let .openUrl(id) = value else { return value }
            return .openUrl(getString(id)?.value)
        }

        func getTextOrNil(from value: AdaptyUI.ViewItem.Text?) -> AdaptyUI.CompoundText? {
            guard let value else { return nil }
            return getText(from: value)
        }

        func getText(from group: AdaptyUI.ViewItem.Text) -> AdaptyUI.CompoundText {
            let defaultFont = getAssetFont(group.fontAssetId)
            let defaultFilling = getAssetFilling(group.fillAssetId)

            return AdaptyUI.CompoundText(
                items: group.items.map({
                    switch $0 {
                    case let .text(item):
                        let font = getAssetFont(item.fontAssetId) ?? defaultFont
                        let str = getString(item.stringId)
                        let text = AdaptyUI.Text(
                            value: str?.value,
                            fallback: str?.fallback,
                            hasTags: str?.hasTags ?? false,
                            font: font,
                            size: item.size ?? group.size ?? font?.defaultSize,
                            fill: getAssetFilling(item.fillAssetId) ?? defaultFilling ?? font?.defaultFilling,
                            horizontalAlign: item.horizontalAlign ?? group.horizontalAlign ?? font?.defaultHorizontalAlign ?? AdaptyUI.Text.defaultHorizontalAlign
                        )
                        return item.isBullet ? .textBullet(text) : .text(text)
                    case let .image(item):
                        let image = AdaptyUI.Text.Image(
                            src: getAssetFilling(item.imageAssetId)?.asImage,
                            tint: getAssetFilling(item.colorAssetId)?.asColor,
                            size: AdaptyUI.Size(width: item.width, height: item.height))
                        return item.isBullet ? .imageBullet(image) : .image(image)
                    case let .space(value):
                        return .space(value)
                    case .newline:
                        return .newline
                    }
                }),
                bulletSpace: group.bulletSpace
            )
        }

        func convert(_ items: [String: AdaptyUI.ViewItem]?) -> [String: AdaptyUI.LocalizedViewItem] {
            items?.mapValues(convert) ?? [:]
        }

        func convert(_ item: [(key: String, value: AdaptyUI.ViewItem)]?) -> [(key: String, value: AdaptyUI.LocalizedViewItem)] {
            item?.map { (key: $0.key, value: convert($0.value)) } ?? []
        }

        func convert(_ item: AdaptyUI.ViewItem.ProductObject) -> AdaptyUI.ProductObject {
            AdaptyUI.ProductObject(productId: item.productId, orderedProperties: convert(item.properties))
        }

        func convert(_ item: AdaptyUI.ViewItem) -> AdaptyUI.LocalizedViewItem {
            switch item {
            case let .asset(id):
                guard let asset = getAsset(id) else {
                    return .unknown("asset.id: \(id)")
                }
                switch asset {
                case let .filling(value):
                    return .filling(value)
                case let .unknown(value):
                    return .unknown(value)
                case .font:
                    return .unknown("unsupported asset {type: font, id: \(id)}")
                }
            case let .shape(value):
                return .shape(getShape(from: value))
            case let .button(value):
                let normal = AdaptyUI.Button.State(
                    shape: getShapeOrNil(from: value.shape),
                    title: getTextOrNil(from: value.title)
                )

                let selected = AdaptyUI.Button.State(
                    shape: getShapeOrNil(from: value.selectedShape),
                    title: getTextOrNil(from: value.selectedTitle)
                )

                return .button(AdaptyUI.Button(
                    normal: normal.isEmpty ? nil : normal,
                    selected: selected.isEmpty ? nil : selected,
                    align: value.align ?? AdaptyUI.Button.defaultAlign,
                    action: getButtonActionOrNil(from: value.action),
                    visibility: value.visibility,
                    transitionIn: value.transitionIn
                ))
            case let .text(group):
                return .text(getText(from: group))
            case let .object(value):
                return .object(AdaptyUI.CustomObject(type: value.type, orderedProperties: convert(value.properties)))
            case .unknown:
                return .unknown("unsupported type")
            }
        }

        var styles = [String: AdaptyUI.LocalizedViewStyle]()
        styles.reserveCapacity(self.styles.count)

        for style in self.styles {
            styles[style.key] = AdaptyUI.LocalizedViewStyle(
                featureBlock: style.value.featuresBlock.map {
                    AdaptyUI.FeaturesBlock(
                        type: $0.type,
                        orderedItems: convert($0.orderedItems)
                    )
                },
                productBlock: AdaptyUI.ProductsBlock(
                    type: style.value.productsBlock.type,
                    mainProductIndex: style.value.productsBlock.mainProductIndex,
                    initiatePurchaseOnTap: style.value.productsBlock.initiatePurchaseOnTap,
                    products: style.value.productsBlock.products.map { convert($0) },
                    orderedItems: convert(style.value.productsBlock.orderedItems)
                ),
                footerBlock: style.value.footerBlock.map {
                    AdaptyUI.FooterBlock(
                        orderedItems: convert($0.orderedItems)
                    )
                },
                items: convert(style.value.items))
        }

        return AdaptyUI.LocalizedViewConfiguration(
            id: id,
            templateId: templateId,
            locale: (localization?.id ?? locale).id,
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

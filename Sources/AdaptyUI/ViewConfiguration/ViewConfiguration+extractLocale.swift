//
//  ViewConfiguration+extractLocale.swift
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

    public func extractLocale(_ locale: String) -> AdaptyUI.LocalizedViewConfiguration {
        extractLocale(AdaptyLocale(id: locale))
    }

    func extractLocale(_ locale: AdaptyLocale) -> AdaptyUI.LocalizedViewConfiguration {
        let localization = getLocalization(locale)

        func getLocalizedAsset(_ id: String?) -> Asset? {
            guard let id else { return nil }
            return localization?.assets?[id] ?? assets[id]
        }

        func getLocalizedUrl(_ id: String?) -> String? {
            guard let id, let item = localization?.strings?[id] else { return nil }
            return item.value.asUrlString ?? item.fallback?.asUrlString
        }

        func getLocalizedRichText(_ id: String?) -> AdaptyUI.RichText? {
            guard let id, let item = localization?.strings?[id] else { return nil }
            return AdaptyUI.RichText(
                items: item.value.convert(getLocalizedAsset),
                fallback: item.fallback.map { $0.convert(getLocalizedAsset) }
            )
        }

        func getLocalizedRichText(_ text: AdaptyUI.ViewConfiguration.Text) -> AdaptyUI.RichText? {
            guard let item = localization?.strings?[text.stringId] else { return nil }
            return AdaptyUI.RichText(
                items: item.value.convert(getLocalizedAsset, defaultAttributes: text),
                fallback: item.fallback.map { $0.convert(getLocalizedAsset, defaultAttributes: text) }
            )
        }

        func convertButtonAction(from value: AdaptyUI.ButtonAction) -> AdaptyUI.ButtonAction {
            guard case let .openUrl(id) = value else { return value }
            return .openUrl(getLocalizedUrl(id))
        }

        func convert(_ items: [String: ViewItem]?) -> [String: AdaptyUI.LocalizedViewItem] {
            items?.mapValues(convert) ?? [:]
        }

        func convert(_ item: [(key: String, value: ViewItem)]?) -> [(key: String, value: AdaptyUI.LocalizedViewItem)] {
            item?.map { (key: $0.key, value: convert($0.value)) } ?? []
        }

        func convert(_ item: ProductObject) -> AdaptyUI.ProductObject {
            AdaptyUI.ProductObject(productId: item.productId, orderedProperties: convert(item.properties))
        }

        func convert(_ item: ViewItem) -> AdaptyUI.LocalizedViewItem {
            switch item {
            case let .asset(id):
                guard let asset = getLocalizedAsset(id) else {
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
                return .shape(value.convert(getLocalizedAsset))
            case let .button(value):

                let normal: AdaptyUI.Button.State = .init(
                    shape: value.shape.map { $0.convert(getLocalizedAsset) },
                    title: value.title.flatMap(getLocalizedRichText)
                )

                let selected = AdaptyUI.Button.State(
                    shape: value.selectedShape.map { $0.convert(getLocalizedAsset) },
                    title: value.selectedTitle.flatMap(getLocalizedRichText)
                )

                return .button(AdaptyUI.Button(
                    normal: normal.isEmpty ? nil : normal,
                    selected: selected.isEmpty ? nil : selected,
                    align: value.align ?? AdaptyUI.Button.defaultAlign,
                    action: value.action.map(convertButtonAction),
                    visibility: value.visibility,
                    transitionIn: value.transitionIn
                ))
            case let .text(value):
                return .text(getLocalizedRichText(value) ?? AdaptyUI.RichText(items: [], fallback: nil))
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
                items: convert(style.value.items)
            )
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

extension AdaptyUI.ViewConfiguration.Localization {
    fileprivate func addDefault(localization: Self?) -> Self {
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

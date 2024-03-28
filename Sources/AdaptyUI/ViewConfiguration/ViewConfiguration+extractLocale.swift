//
//  ViewConfiguration+extractLocale.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    public func extractLocale(_ locale: String) -> AdaptyUI.LocalizedViewConfiguration {
        extractLocale(AdaptyLocale(id: locale))
    }

    func extractLocale(_ locale: AdaptyLocale) -> AdaptyUI.LocalizedViewConfiguration {
        let localizer = Localizer(from: self, withLocale: locale)

        func convert(_ items: [String: OldViewItem]?) -> [String: AdaptyUI.OldViewItem] {
            items?.mapValues(convert) ?? [:]
        }

        func convert(_ item: [(key: String, value: OldViewItem)]?) -> [(key: String, value: AdaptyUI.OldViewItem)] {
            item?.map { (key: $0.key, value: convert($0.value)) } ?? []
        }

        func convert(_ item: OldProductObject) -> AdaptyUI.OldProductObject {
            AdaptyUI.OldProductObject(productId: item.productId, orderedProperties: convert(item.properties))
        }

        func convert(_ item: OldViewItem) -> AdaptyUI.OldViewItem {
            switch item {
            case let .asset(id):
                guard let asset = localizer.assetIfPresent(id) else {
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
                return .shape(localizer.decorator(from: value))
            case let .button(value):

                let normal: AdaptyUI.OldButton.State = .init(
                    shape: value.shape.map(localizer.decorator),
                    title: value.title.flatMap(localizer.richText)
                )

                let selected = AdaptyUI.OldButton.State(
                    shape: value.selectedShape.map(localizer.decorator),
                    title: value.selectedTitle.flatMap(localizer.richText)
                )

                return .button(AdaptyUI.OldButton(
                    normal: normal.isEmpty ? nil : normal,
                    selected: selected.isEmpty ? nil : selected,
                    align: value.align ?? AdaptyUI.OldButton.defaultAlign,
                    action: value.action.map(localizer.buttonAction),
                    visibility: value.visibility,
                    transitionIn: value.transitionIn
                ))
            case let .text(value):
                return .text(localizer.richText(from: value))
            case let .object(value):
                return .object(AdaptyUI.OldCustomObject(type: value.type, orderedProperties: convert(value.properties)))
            case .unknown:
                return .unknown("unsupported type")
            }
        }

        var styles = [String: AdaptyUI.OldViewStyle]()
        styles.reserveCapacity(self.styles.count)

        for style in self.styles {
            styles[style.key] = AdaptyUI.OldViewStyle(
                featureBlock: style.value.featuresBlock.map {
                    AdaptyUI.OldFeaturesBlock(
                        type: $0.type,
                        orderedItems: convert($0.orderedItems)
                    )
                },
                productBlock: AdaptyUI.OldProductsBlock(
                    type: style.value.productsBlock.type,
                    mainProductIndex: style.value.productsBlock.mainProductIndex,
                    initiatePurchaseOnTap: style.value.productsBlock.initiatePurchaseOnTap,
                    products: style.value.productsBlock.products.map { convert($0) },
                    orderedItems: convert(style.value.productsBlock.orderedItems)
                ),
                footerBlock: style.value.footerBlock.map {
                    AdaptyUI.OldFooterBlock(
                        orderedItems: convert($0.orderedItems)
                    )
                },
                items: convert(style.value.items)
            )
        }

        return AdaptyUI.LocalizedViewConfiguration(
            id: id,
            templateId: templateId,
            locale: localizer.locale.id,
            styles: styles,
            isHard: isHard,
            mainImageRelativeHeight: mainImageRelativeHeight,
            version: version
        )
    }
}

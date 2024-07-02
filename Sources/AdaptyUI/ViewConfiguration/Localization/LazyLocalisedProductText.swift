//
//  LazyLocalisedProductText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 02.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct LazyLocalisedProductText: Hashable, Sendable {
        package let adaptyProductId: String
        private let suffix: String?
        private let localizer: ViewConfiguration.Localizer
        private let defaultTextAttributes: ViewConfiguration.TextAttributes?

        init(
            adaptyProductId: String,
            suffix: String?,
            localizer: ViewConfiguration.Localizer,
            defaultTextAttributes: ViewConfiguration.TextAttributes?
        ) {
            self.adaptyProductId = adaptyProductId
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
        }

        package func richText(
            byPaymentMode mode: AdaptyProductDiscount.PaymentMode = .unknown
        ) -> RichText {
            localizer.richText(
                adaptyProductId: adaptyProductId,
                byPaymentMode: mode,
                suffix: suffix,
                defaultTextAttributes: defaultTextAttributes
            )
        }
    }

    package struct LazyLocalisedUnknownProductText: Hashable, Sendable {
        package let productGroupId: String
        private let suffix: String?
        private let localizer: ViewConfiguration.Localizer
        private let defaultTextAttributes: ViewConfiguration.TextAttributes?

        init(
            productGroupId: String,
            suffix: String?,
            localizer: ViewConfiguration.Localizer,
            defaultTextAttributes: ViewConfiguration.TextAttributes?
        ) {
            self.productGroupId = productGroupId
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
        }

        package func richText() -> RichText {
            localizer.richText(
                stringId: ViewConfiguration.StringId.Product.calculate(
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) ?? .empty
        }

        package func richText(
            adaptyProductId: String,
            byPaymentMode mode: AdaptyProductDiscount.PaymentMode = .unknown
        ) -> RichText {
            localizer.richText(
                adaptyProductId: adaptyProductId,
                byPaymentMode: mode,
                suffix: suffix,
                defaultTextAttributes: defaultTextAttributes
            )
        }
    }
}

private extension AdaptyUI.ViewConfiguration.Localizer {
    func richText(
        adaptyProductId: String,
        byPaymentMode mode: AdaptyProductDiscount.PaymentMode = .unknown,
        suffix: String?,
        defaultTextAttributes: AdaptyUI.ViewConfiguration.TextAttributes?
    ) -> AdaptyUI.RichText {
        if
            let value = richText(
                stringId: AdaptyUI.ViewConfiguration.StringId.Product.calculate(
                    adaptyProductId: adaptyProductId,
                    byPaymentMode: mode,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else if
            mode != .unknown,
            let value = richText(
                stringId: AdaptyUI.ViewConfiguration.StringId.Product.calculate(
                    adaptyProductId: adaptyProductId,
                    byPaymentMode: .unknown,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else if
            let value = richText(
                stringId: AdaptyUI.ViewConfiguration.StringId.Product.calculate(
                    byPaymentMode: mode,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else if
            mode != .unknown,
            let value = richText(
                stringId: AdaptyUI.ViewConfiguration.StringId.Product.calculate(
                    byPaymentMode: .unknown,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else {
            .empty
        }
    }
}

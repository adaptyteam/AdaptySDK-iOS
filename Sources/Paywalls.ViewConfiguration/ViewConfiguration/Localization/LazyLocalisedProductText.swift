//
//  LazyLocalisedProductText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 02.05.2024
//
//

import Foundation

extension AdaptyUICore {
    package struct LazyLocalisedProductText: Sendable, Hashable {
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
            byPaymentMode mode: AdaptySubscriptionOffer.PaymentMode = .unknown
        ) -> RichText {
            localizer.richText(
                adaptyProductId: adaptyProductId,
                byPaymentMode: mode,
                suffix: suffix,
                defaultTextAttributes: defaultTextAttributes
            )
        }
    }

    package struct LazyLocalisedUnknownProductText: Sendable, Hashable {
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
            byPaymentMode mode: AdaptySubscriptionOffer.PaymentMode = .unknown
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

private extension AdaptyUICore.ViewConfiguration.Localizer {
    func richText(
        adaptyProductId: String,
        byPaymentMode mode: AdaptySubscriptionOffer.PaymentMode = .unknown,
        suffix: String?,
        defaultTextAttributes: AdaptyUICore.ViewConfiguration.TextAttributes?
    ) -> AdaptyUICore.RichText {
        if
            let value = richText(
                stringId: AdaptyUICore.ViewConfiguration.StringId.Product.calculate(
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
                stringId: AdaptyUICore.ViewConfiguration.StringId.Product.calculate(
                    adaptyProductId: adaptyProductId,
                    byPaymentMode: .unknown,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else if
            let value = richText(
                stringId: AdaptyUICore.ViewConfiguration.StringId.Product.calculate(
                    byPaymentMode: mode,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else if
            mode != .unknown,
            let value = richText(
                stringId: AdaptyUICore.ViewConfiguration.StringId.Product.calculate(
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

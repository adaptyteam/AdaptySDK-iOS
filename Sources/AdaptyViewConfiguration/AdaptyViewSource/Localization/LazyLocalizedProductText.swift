//
//  LazyLocalizedProductText.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.05.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct LazyLocalizedProductText: Sendable, Hashable {
        package let adaptyProductId: String
        private let suffix: String?
        private let localizer: AdaptyViewSource.Localizer
        private let defaultTextAttributes: AdaptyViewSource.TextAttributes?

        init(
            adaptyProductId: String,
            suffix: String?,
            localizer: AdaptyViewSource.Localizer,
            defaultTextAttributes: AdaptyViewSource.TextAttributes?
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

    package struct LazyLocalizedUnknownProductText: Sendable, Hashable {
        package let productGroupId: String
        private let suffix: String?
        private let localizer: AdaptyViewSource.Localizer
        private let defaultTextAttributes: AdaptyViewSource.TextAttributes?

        init(
            productGroupId: String,
            suffix: String?,
            localizer: AdaptyViewSource.Localizer,
            defaultTextAttributes: AdaptyViewSource.TextAttributes?
        ) {
            self.productGroupId = productGroupId
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
        }

        package func richText() -> RichText {
            localizer.richText(
                stringId: AdaptyViewSource.StringId.Product.calculate(
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

private extension AdaptyViewSource.Localizer {
    func richText(
        adaptyProductId: String,
        byPaymentMode mode: AdaptySubscriptionOffer.PaymentMode = .unknown,
        suffix: String?,
        defaultTextAttributes: AdaptyViewSource.TextAttributes?
    ) -> AdaptyViewConfiguration.RichText {
        if
            let value = richText(
                stringId: AdaptyViewSource.StringId.Product.calculate(
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
                stringId: AdaptyViewSource.StringId.Product.calculate(
                    adaptyProductId: adaptyProductId,
                    byPaymentMode: .unknown,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else if
            let value = richText(
                stringId: AdaptyViewSource.StringId.Product.calculate(
                    byPaymentMode: mode,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else if
            mode != .unknown,
            let value = richText(
                stringId: AdaptyViewSource.StringId.Product.calculate(
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

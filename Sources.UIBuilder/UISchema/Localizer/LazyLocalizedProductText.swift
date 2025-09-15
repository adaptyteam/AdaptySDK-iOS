//
//  LazyLocalizedProductText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 02.05.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    struct LazyLocalizedProductText: Sendable, Hashable {
        package let adaptyProductId: String
        private let suffix: String?
        private let localizer: Schema.Localizer
        private let defaultTextAttributes: Schema.TextAttributes?

        init(
            adaptyProductId: String,
            suffix: String?,
            localizer: Schema.Localizer,
            defaultTextAttributes: Schema.TextAttributes?
        ) {
            self.adaptyProductId = adaptyProductId
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
        }

        package func richText(
            byPaymentMode paymentMode: PaymentModeValue = nil
        ) -> RichText {
            localizer.richText(
                adaptyProductId: adaptyProductId,
                byPaymentMode: paymentMode,
                suffix: suffix,
                defaultTextAttributes: defaultTextAttributes
            )
        }
    }

    struct LazyLocalizedUnknownProductText: Sendable, Hashable {
        package let productGroupId: String
        private let suffix: String?
        private let localizer: Schema.Localizer
        private let defaultTextAttributes: Schema.TextAttributes?

        init(
            productGroupId: String,
            suffix: String?,
            localizer: Schema.Localizer,
            defaultTextAttributes: Schema.TextAttributes?
        ) {
            self.productGroupId = productGroupId
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
        }

        package func richText() -> RichText {
            localizer.richText(
                stringId: Schema.StringId.Product.calculate(
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) ?? .empty
        }

        package func richText(
            adaptyProductId: String,
            byPaymentMode paymentMode: PaymentModeValue = nil
        ) -> RichText {
            localizer.richText(
                adaptyProductId: adaptyProductId,
                byPaymentMode: paymentMode,
                suffix: suffix,
                defaultTextAttributes: defaultTextAttributes
            )
        }
    }
}

private extension Schema.Localizer {
    func richText(
        adaptyProductId: String,
        byPaymentMode paymentMode: PaymentModeValue = nil,
        suffix: String?,
        defaultTextAttributes: Schema.TextAttributes?
    ) -> AdaptyViewConfiguration.RichText {
        if let value = richText(
            stringId: Schema.StringId.Product.calculate(
                adaptyProductId: adaptyProductId,
                byPaymentMode: paymentMode,
                suffix: suffix
            ),
            defaultTextAttributes: defaultTextAttributes
        ) { return value }
        if paymentMode != nil, let value = richText(
            stringId: Schema.StringId.Product.calculate(
                adaptyProductId: adaptyProductId,
                byPaymentMode: nil,
                suffix: suffix
            ),
            defaultTextAttributes: defaultTextAttributes
        ) { return value }
        if let value = richText(
            stringId: Schema.StringId.Product.calculate(
                byPaymentMode: paymentMode,
                suffix: suffix
            ),
            defaultTextAttributes: defaultTextAttributes
        ) { return value }
        if paymentMode != nil, let value = richText(
            stringId: Schema.StringId.Product.calculate(
                byPaymentMode: nil,
                suffix: suffix
            ),
            defaultTextAttributes: defaultTextAttributes
        ) { return value }
        return .empty
    }
}

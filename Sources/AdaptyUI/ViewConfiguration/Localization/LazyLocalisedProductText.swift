//
//  LazyLocalisedProductText.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 02.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct LazyLocalisedProductText {
        package let adaptyProductId: String
        private let suffix: String?
        private let localizer: ViewConfiguration.Localizer
        private let defaultTextAttributes: ViewConfiguration.TextAttributes?
        private let defaultParagraphAttributes: ViewConfiguration.ParagraphAttributes?

        init(
            adaptyProductId: String,
            suffix: String?,
            localizer: ViewConfiguration.Localizer,
            defaultTextAttributes: ViewConfiguration.TextAttributes?,
            defaultParagraphAttributes: ViewConfiguration.ParagraphAttributes?
        ) {
            self.adaptyProductId = adaptyProductId
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
            self.defaultParagraphAttributes = defaultParagraphAttributes
        }
        
        package func richText(
            byPaymentMode mode: AdaptyProductDiscount.PaymentMode = .unknown
        ) -> RichText {
            localizer.richText(
                stringId: ViewConfiguration.StringId.Product.calculate(
                    adaptyProductId: adaptyProductId,
                    byPaymentMode: mode,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes,
                defaultParagraphAttributes: defaultParagraphAttributes
            )
        }
    }

    package struct LazyLocalisedUnknownProductText {
        private let suffix: String?
        private let localizer: ViewConfiguration.Localizer
        private let defaultTextAttributes: ViewConfiguration.TextAttributes?
        private let defaultParagraphAttributes: ViewConfiguration.ParagraphAttributes?

        init(
            suffix: String?,
            localizer: ViewConfiguration.Localizer,
            defaultTextAttributes: ViewConfiguration.TextAttributes?,
            defaultParagraphAttributes: ViewConfiguration.ParagraphAttributes?
        ) {
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
            self.defaultParagraphAttributes = defaultParagraphAttributes
        }
        
        package func richText() -> RichText {
            localizer.richText(
                stringId: ViewConfiguration.StringId.Product.calculate(
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes,
                defaultParagraphAttributes: defaultParagraphAttributes
            )
        }
        
        package func richText(
            adaptyProductId: String,
            byPaymentMode mode: AdaptyProductDiscount.PaymentMode = .unknown
        ) -> RichText {
            localizer.richText(
                stringId: ViewConfiguration.StringId.Product.calculate(
                    adaptyProductId: adaptyProductId,
                    byPaymentMode: mode,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes,
                defaultParagraphAttributes: defaultParagraphAttributes
            )
        }
    }
}

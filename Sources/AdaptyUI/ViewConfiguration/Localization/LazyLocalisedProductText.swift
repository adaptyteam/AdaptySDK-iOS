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
        private let sufix: String?
        private let localizer: ViewConfiguration.Localizer
        private let defaultTextAttributes: ViewConfiguration.TextAttributes?
        private let defaultParagraphAttributes: ViewConfiguration.ParagraphAttributes?

        init(
            adaptyProductId: String,
            sufix: String?,
            localizer: ViewConfiguration.Localizer,
            defaultTextAttributes: ViewConfiguration.TextAttributes?,
            defaultParagraphAttributes: ViewConfiguration.ParagraphAttributes?
        ) {
            self.adaptyProductId = adaptyProductId
            self.sufix = sufix
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
                    sufix: sufix
                ),
                defaultTextAttributes: defaultTextAttributes,
                defaultParagraphAttributes: defaultParagraphAttributes
            )
        }
    }

    package struct LazyLocalisedUnknownProductText {
        private let sufix: String?
        private let localizer: ViewConfiguration.Localizer
        private let defaultTextAttributes: ViewConfiguration.TextAttributes?
        private let defaultParagraphAttributes: ViewConfiguration.ParagraphAttributes?

        init(
            sufix: String?,
            localizer: ViewConfiguration.Localizer,
            defaultTextAttributes: ViewConfiguration.TextAttributes?,
            defaultParagraphAttributes: ViewConfiguration.ParagraphAttributes?
        ) {
            self.sufix = sufix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
            self.defaultParagraphAttributes = defaultParagraphAttributes
        }
        
        package func richText(
            adaptyProductId: String,
            byPaymentMode mode: AdaptyProductDiscount.PaymentMode = .unknown
        ) -> RichText {
            localizer.richText(
                stringId: ViewConfiguration.StringId.Product.calculate(
                    adaptyProductId: adaptyProductId,
                    byPaymentMode: mode,
                    sufix: sufix
                ),
                defaultTextAttributes: defaultTextAttributes,
                defaultParagraphAttributes: defaultParagraphAttributes
            )
        }
    }
}

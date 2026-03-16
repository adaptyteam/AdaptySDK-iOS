//
//  VS+RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.01.2026.
//

import Foundation

extension VS {
    func richText(
        _ stringId: VC.StringIdentifier
    ) throws(VS.Error) -> VC.RichText? {
        configuration.strings[stringId]
    }

    func richTextForNonSelectedProduct(
        suffix: String?
    ) throws(VS.Error) -> VC.RichText? {
        configuration.strings[
            Schema.StringReference.Product.calculate(
                suffix: suffix
            )
        ]
    }

    func richText(
        adaptyProductId: String,
        byPaymentMode paymentMode: PaymentModeValue = nil,
        suffix: String?
    ) throws(VS.Error) -> VC.RichText? {
        if let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                adaptyProductId: adaptyProductId,
                byPaymentMode: paymentMode,
                suffix: suffix
            )
        ] { return value }

        if paymentMode != nil, let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                adaptyProductId: adaptyProductId,
                byPaymentMode: nil,
                suffix: suffix
            )
        ] { return value }

        if let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                byPaymentMode: paymentMode,
                suffix: suffix
            )
        ] { return value }

        if paymentMode != nil, let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                byPaymentMode: nil,
                suffix: suffix
            )
        ] { return value }

        return nil
    }
}

//
//  VS+RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.01.2026.
//

import Foundation

extension VS {
    @inlinable
    func richText(
        _ stringId: VC.StringIdentifier,
        defaultAttributes: VC.RichText.Attributes?
    ) throws(VS.Error) -> VC.RichText? {
        configuration.strings[stringId]?.apply(defaultAttributes: defaultAttributes)
    }

    @inlinable
    func richText(
        suffix: String?,
        defaultAttributes: VC.RichText.Attributes?
    ) throws(VS.Error) -> VC.RichText? {
        configuration.strings[
            Schema.StringReference.Product.calculate(
                suffix: suffix
            )
        ]?.apply(defaultAttributes: defaultAttributes)
    }

    @inlinable
    func richText(
        adaptyProductId: String,
        byPaymentMode paymentMode: PaymentModeValue = nil,
        suffix: String?,
        defaultAttributes: VC.RichText.Attributes?
    ) throws(VS.Error) -> VC.RichText? {
        if let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                adaptyProductId: adaptyProductId,
                byPaymentMode: paymentMode,
                suffix: suffix
            )
        ] { return value.apply(defaultAttributes: defaultAttributes) }

        if paymentMode != nil, let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                adaptyProductId: adaptyProductId,
                byPaymentMode: nil,
                suffix: suffix
            )
        ] { return value.apply(defaultAttributes: defaultAttributes) }

        if let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                byPaymentMode: paymentMode,
                suffix: suffix
            )
        ] { return value.apply(defaultAttributes: defaultAttributes) }

        if paymentMode != nil, let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                byPaymentMode: nil,
                suffix: suffix
            )
        ] { return value.apply(defaultAttributes: defaultAttributes) }

        return nil
    }
}

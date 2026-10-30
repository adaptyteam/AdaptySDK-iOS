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
            Schema.StringReference.Product.calculateNonSelected(
                suffix: suffix
            )
        ]
    }

    func richText(
        adaptyProductId: String,
        billingPlan: BillingPlanId?,
        paymentMode: PaymentModeId?,
        suffix: String?
    ) throws(VS.Error) -> VC.RichText? {
//        let billingPlan = billingPlan ?? "up_front"
        if let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                adaptyProductId: adaptyProductId,
                billingPlan: billingPlan,
                paymentMode: paymentMode,
                suffix: suffix
            )
        ] { return value }

        if paymentMode != nil, let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                adaptyProductId: adaptyProductId,
                billingPlan: billingPlan,
                paymentMode: nil,
                suffix: suffix
            )
        ] { return value }

        if let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                adaptyProductId: adaptyProductId,
                billingPlan: nil,
                paymentMode: paymentMode,
                suffix: suffix
            )
        ] { return value }

        if paymentMode != nil, let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                adaptyProductId: adaptyProductId,
                billingPlan: nil,
                paymentMode: nil,
                suffix: suffix
            )
        ] { return value }

        if let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                billingPlan: billingPlan,
                paymentMode: paymentMode,
                suffix: suffix
            )
        ] { return value }

        if paymentMode != nil, let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                billingPlan: billingPlan,
                paymentMode: nil,
                suffix: suffix
            )
        ] { return value }

        if let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                billingPlan: nil,
                paymentMode: paymentMode,
                suffix: suffix
            )
        ] { return value }

        if paymentMode != nil, let value = configuration.strings[
            Schema.StringReference.Product.calculate(
                billingPlan: nil,
                paymentMode: nil,
                suffix: suffix
            )
        ] { return value }

        return nil
    }
}

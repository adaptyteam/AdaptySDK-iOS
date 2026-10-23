//
//  VC.StringReference.Product.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

extension VC.StringReference {
    enum Product: Sendable {
        case id(String, sufix: String?)
        case variable(VC.Variable, sufix: String?)
    }
}

extension VC.StringReference.Product {
    static func calculateNonSelected(suffix: String?) -> String {
        if let suffix {
            "PRODUCT_not_selected_\(suffix)"
        } else {
            "PRODUCT_not_selected"
        }
    }

    static func calculate(
        adaptyProductId: String,
        billingPlan: BillingPlanId?,
        paymentMode: PaymentModeId?,
        suffix: String?
    ) -> String {
       let billingPart = billingPlan.map { "_bil_\($0)" } ?? ""
       let paymentMode = paymentMode ?? "default"
       let base = "PRODUCT_\(adaptyProductId)\(billingPart)_\(paymentMode)"
       return if let suffix { "\(base)_\(suffix)" } else {  base }
    }

    static func calculate(
        billingPlan: BillingPlanId?,
        paymentMode: PaymentModeId?,
        suffix: String?
    ) -> String {
        let billingPart = billingPlan.map { "_bil_\($0)" } ?? ""
        let paymentMode = paymentMode ?? "default"
        let base = "PRODUCT\(billingPart)_\(paymentMode)"
        return if let suffix { "\(base)_\(suffix)" } else {  base }
    }
}

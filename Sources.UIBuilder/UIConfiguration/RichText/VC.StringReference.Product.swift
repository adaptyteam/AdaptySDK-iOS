//
//  VC.StringReference.Product.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

package extension VC.StringReference {
    enum Product: Sendable, Hashable {
        case id(String, sufix: String?)
        case variable(VC.Variable, sufix: String?)
    }
}





extension VC.StringReference.Product {
    static func calculate(suffix: String?) -> String {
        if let suffix {
            "PRODUCT_not_selected_\(suffix)"
        } else {
            "PRODUCT_not_selected"
        }
    }

    static func calculate(
        adaptyProductId: String,
        byPaymentMode paymentMode: PaymentModeValue,
        suffix: String?
    ) -> String {
        let paymentMode = paymentMode ?? "default"
        return if let suffix {
            "PRODUCT_\(adaptyProductId)_\(paymentMode)_\(suffix)"
        } else {
            "PRODUCT_\(adaptyProductId)_\(paymentMode)"
        }
    }

    static func calculate(
        byPaymentMode paymentMode: PaymentModeValue,
        suffix: String?
    ) -> String {
        let paymentMode = paymentMode ?? "default"
        return if let suffix {
            "PRODUCT_\(paymentMode)_\(suffix)"
        } else {
            "PRODUCT_\(paymentMode)"
        }
    }
}

//
//  VC.StringReference.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.01.2026.
//

import Foundation

package extension VC {
    enum StringReference: Sendable, Hashable {
        case stringId(String)
        case product(Product)
        case variable(Variable)
    }
}

package extension VC.StringReference {
    struct Product: Sendable, Hashable {
        package let adaptyProductId: String?
        package let productGroupId: String?
        package let suffix: String?
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

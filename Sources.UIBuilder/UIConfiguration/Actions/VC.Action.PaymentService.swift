//
//  VC.Action.PaymentService.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2025.
//

import Foundation

package extension VC.Action {
    enum PaymentService: Sendable, Hashable {
        case storeKit
        case openWebPaywall(openIn: WebOpenInParameter)
    }
}

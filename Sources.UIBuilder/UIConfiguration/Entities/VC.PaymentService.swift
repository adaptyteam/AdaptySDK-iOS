//
//  VC.PaymentService.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2025.
//

import Foundation

package extension VC {
    enum PaymentService: Hashable, Sendable {
        case storeKit
        case openWebPaywall(openIn: WebOpenInParameter)
    }
}

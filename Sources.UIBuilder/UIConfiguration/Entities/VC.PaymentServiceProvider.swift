//
//  VC.PaymentServiceProvider.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2025.
//

import Foundation

package extension VC {
    enum PaymentServiceProvider: Hashable, Sendable {
        case storeKit
        case openWebPaywall
    }
}

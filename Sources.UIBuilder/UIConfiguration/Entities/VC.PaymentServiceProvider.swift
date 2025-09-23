//
//  PaymentServiceProvider.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2025.
//

import Foundation

package extension AdaptyUIConfiguration {
    enum PaymentServiceProvider: Hashable, Sendable {
        case storeKit
        case openWebPaywall
    }
}

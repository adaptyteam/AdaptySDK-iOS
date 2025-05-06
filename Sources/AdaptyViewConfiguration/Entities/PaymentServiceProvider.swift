//
//  PaymentServiceProvider.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.05.2025.
//

import Foundation

package extension AdaptyViewConfiguration {
    enum PaymentServiceProvider: Hashable, Sendable {
        case storeKit
        case openWebPaywall
    }
}

//
//  AdaptyUIBuilder+Models.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 9/23/25.
//

import Foundation

public extension AdaptyUIBuilder {
    enum Action {
        case close
        case openURL(url: URL)
        case custom(id: String)
    }
}

public protocol ProductResolver: Sendable {
    var adaptyProductId: String { get }
    var paymentMode: PaymentModeValue { get }

    func value(byTag tag: TextProductTag) -> TextTagValue?
}

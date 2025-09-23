//
//  AdaptyUIBuilder+Models.swift
//  Adapty
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

public protocol AdaptyPaywallModel {
    var placementId: String { get }
    var variationId: String { get }
    var locale: String? { get }
    var vendorProductIds: [String] { get }
}

// TODO: check this
package protocol AdaptyProductModel: Sendable {
    var vendorProductId: String { get }
    var adaptyProductId: String { get }
    var paymentMode: String? { get } // PaymentModeValue

    func stringByTag(_ tag: AdaptyUIConfiguration.ProductTag) -> VC.ProductTagReplacement?
}

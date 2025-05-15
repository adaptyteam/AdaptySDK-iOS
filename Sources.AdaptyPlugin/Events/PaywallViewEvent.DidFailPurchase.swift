//
//  PaywallViewEvent.DidFailPurchase.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 21.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension PaywallViewEvent {
    struct DidFailPurchase: AdaptyPluginEvent {
        let id = "paywall_view_did_fail_purchase"
        let view: AdaptyUI.PaywallView
        let product: Response.AdaptyPluginPaywallProduct
        let error: AdaptyError

        enum CodingKeys: CodingKey {
            case id
            case view
            case product
            case error
        }
    }
}

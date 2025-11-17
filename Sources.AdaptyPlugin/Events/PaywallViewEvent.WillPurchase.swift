//
//  PaywallViewEvent.WillPurchase.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension PaywallViewEvent {
    struct WillPurchase: AdaptyPluginEvent {
        let id = "paywall_view_did_start_purchase"
        let view: AdaptyUI.PaywallView
        let product: Response.AdaptyPluginPaywallProduct

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case product
        }
    }
}

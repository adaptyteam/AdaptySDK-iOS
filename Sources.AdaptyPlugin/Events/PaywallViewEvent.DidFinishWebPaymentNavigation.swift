//
//  PaywallViewEvent.DidFinishWebPaymentNavigation.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/7/25.
//

import Adapty
import AdaptyUI
import Foundation

extension PaywallViewEvent {
    struct DidFinishWebPaymentNavigation: AdaptyPluginEvent {
        let id = "paywall_view_did_finish_web_payment_navigation"
        let view: AdaptyUI.PaywallView
        let product: Response.AdaptyPluginPaywallProduct?
        let error: AdaptyError?

        enum CodingKeys: CodingKey {
            case id
            case view
            case product
            case error
        }
    }
}

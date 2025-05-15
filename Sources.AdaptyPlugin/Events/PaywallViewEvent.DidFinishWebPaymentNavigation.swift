//
//  PaywallViewEvent.DidFinishWebPaymentNavigation.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/7/25.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

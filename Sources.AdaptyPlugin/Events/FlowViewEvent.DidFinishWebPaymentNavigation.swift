//
//  FlowViewEvent.DidFinishWebPaymentNavigation.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/7/25.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidFinishWebPaymentNavigation: AdaptyPluginEvent {
        let id = "flow_view_did_finish_web_payment_navigation"
        let view: AdaptyUI.FlowView
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

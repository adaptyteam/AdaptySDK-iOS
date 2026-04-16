//
//  FlowViewEvent.DidFailPurchase.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 21.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidFailPurchase: AdaptyPluginEvent {
        let id = "flow_view_did_fail_purchase"
        let view: AdaptyUI.FlowView
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

//
//  FlowViewEvent.DidPurchase.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidPurchase: AdaptyPluginEvent {
        let id = "flow_view_did_finish_purchase"
        let view: AdaptyUI.FlowView
        let product: Response.AdaptyPluginPaywallProduct
        let purchasedResult: AdaptyPurchaseResult

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case product
            case purchasedResult = "purchased_result"
        }
    }
}

//
//  FlowViewEvent.WillPurchase.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct WillPurchase: AdaptyPluginEvent {
        let id = "flow_view_did_start_purchase"
        let view: AdaptyUI.FlowView
        let product: Response.AdaptyPluginPaywallProduct

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case product
        }
    }
}

//
//  FlowViewEvent.ObserverDidInitiatePurchase.swift
//  AdaptyPlugin
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct ObserverDidInitiatePurchase: AdaptyPluginEvent {
        let id = "flow_view_observer_did_initiate_purchase"
        let view: AdaptyUI.FlowView
        let eventId: String
        let product: Response.AdaptyPluginPaywallProduct

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case eventId = "event_id"
            case product
        }
    }
}

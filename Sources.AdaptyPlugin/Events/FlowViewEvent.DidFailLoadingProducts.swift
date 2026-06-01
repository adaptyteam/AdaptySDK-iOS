//
//  FlowViewEvent.DidFailLoadingProducts.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidFailLoadingProducts: AdaptyPluginEvent {
        let id = "flow_view_did_fail_loading_products"
        let view: AdaptyUI.FlowView
        let error: AdaptyError

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case error
        }
    }
}

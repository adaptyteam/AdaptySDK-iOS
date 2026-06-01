//
//  FlowViewEvent.DidSelectProduct.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidSelectProduct: AdaptyPluginEvent {
        let id = "flow_view_did_select_product"
        let view: AdaptyUI.FlowView
        let productVendorId: String

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case productVendorId = "product_id"
        }
    }
}

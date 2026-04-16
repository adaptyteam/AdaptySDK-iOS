//
//  FlowViewEvent.WillRestorePurchases.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct WillRestorePurchases: AdaptyPluginEvent {
        let id = "flow_view_did_start_restore"
        let view: AdaptyUI.FlowView

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

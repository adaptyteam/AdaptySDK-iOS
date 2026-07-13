//
//  FlowViewEvent.DidFailRestorePurchases.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 21.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidFailRestorePurchases: AdaptyPluginEvent {
        let id = "flow_view_did_fail_restore"
        let view: AdaptyUI.FlowView
        let error: AdaptyError

        enum CodingKeys: CodingKey {
            case id
            case view
            case error
        }
    }
}

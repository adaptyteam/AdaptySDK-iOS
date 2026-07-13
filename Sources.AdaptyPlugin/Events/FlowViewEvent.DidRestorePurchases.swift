//
//  FlowViewEvent.DidRestorePurchases.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidRestorePurchases: AdaptyPluginEvent {
        let id = "flow_view_did_finish_restore"
        let view: AdaptyUI.FlowView
        let profile: AdaptyProfile

        enum CodingKeys: CodingKey {
            case id
            case view
            case profile
        }
    }
}

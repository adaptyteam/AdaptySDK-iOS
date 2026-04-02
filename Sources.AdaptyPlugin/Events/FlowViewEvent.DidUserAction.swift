//
//  FlowViewEvent.DidUserAction.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidUserAction: AdaptyPluginEvent {
        let id = "flow_view_did_perform_action"
        let view: AdaptyUI.FlowView
        let action: AdaptyUI.Action

        enum CodingKeys: CodingKey {
            case id
            case view
            case action
        }
    }
}

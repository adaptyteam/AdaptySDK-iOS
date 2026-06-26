//
//  FlowViewEvent.DidAskPermission.swift
//  AdaptyPlugin
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidAskPermission: AdaptyPluginEvent {
        let id = "flow_view_did_ask_permission"
        let view: AdaptyUI.FlowView
        let eventId: String
        let permission: String
        let customArgs: [String: String]?

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case eventId = "event_id"
            case permission
            case customArgs = "custom_args"
        }
    }
}

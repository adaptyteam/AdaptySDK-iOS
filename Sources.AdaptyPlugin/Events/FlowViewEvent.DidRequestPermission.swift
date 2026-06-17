//
//  FlowViewEvent.DidRequestPermission.swift
//  AdaptyPlugin
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidRequestPermission: AdaptyPluginEvent {
        let id = "flow_view_did_request_permission"
        let view: AdaptyUI.FlowView
        let requestId: String
        let permission: String
        let customArgs: [String: String]?

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case requestId = "request_id"
            case permission
            case customArgs = "custom_args"
        }
    }
}

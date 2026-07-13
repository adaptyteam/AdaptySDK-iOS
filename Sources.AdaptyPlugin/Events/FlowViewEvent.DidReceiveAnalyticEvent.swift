//
//  FlowViewEvent.DidReceiveAnalyticEvent.swift
//  AdaptyPlugin
//

import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidReceiveAnalyticEvent: AdaptyPluginEvent {
        let id = "flow_view_did_receive_analytic_event"
        let view: AdaptyUI.FlowView
        let name: String
        let params: [String: any Sendable]

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case name
            case params
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(view, forKey: .view)
            try container.encode(name, forKey: .name)
            try container.encode(params.mapValues(PluginJSONValue.init), forKey: .params)
        }
    }
}

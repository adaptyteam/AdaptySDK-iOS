//
//  FlowViewEvent.DidReceiveError.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidReceiveError: AdaptyPluginEvent {
        let id = "flow_view_did_receive_error"
        let view: AdaptyUI.FlowView
        let error: AdaptyUIError

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case error
        }
    }
}

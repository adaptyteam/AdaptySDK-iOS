//
//  FlowViewEvent.DidFailRendering.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidFailRendering: AdaptyPluginEvent {
        let id = "flow_view_did_fail_rendering"
        let view: AdaptyUI.FlowView
        let error: AdaptyUIError

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case error
        }
    }
}

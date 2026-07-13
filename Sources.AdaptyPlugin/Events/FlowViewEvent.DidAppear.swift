//
//  FlowViewEvent.DidAppear.swift
//  AdaptyPlugin
//
//  Created by Alexey Goncharov on 3/13/25.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidAppear: AdaptyPluginEvent {
        let id = "flow_view_did_appear"
        let view: AdaptyUI.FlowView

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

//
//  FlowViewEvent.DidDisappear.swift
//  AdaptyPlugin
//
//  Created by Alexey Goncharov on 3/13/25.
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidDisappear: AdaptyPluginEvent {
        let id = "flow_view_did_disappear"
        let view: AdaptyUI.FlowView

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

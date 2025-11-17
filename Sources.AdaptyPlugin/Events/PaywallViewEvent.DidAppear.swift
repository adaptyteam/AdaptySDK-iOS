//
//  PaywallViewEvent.DidAppear.swift
//  AdaptyPlugin
//
//  Created by Alexey Goncharov on 3/13/25.
//

import Adapty
import AdaptyUI
import Foundation

extension PaywallViewEvent {
    struct DidAppear: AdaptyPluginEvent {
        let id = "paywall_view_did_appear"
        let view: AdaptyUI.PaywallView

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

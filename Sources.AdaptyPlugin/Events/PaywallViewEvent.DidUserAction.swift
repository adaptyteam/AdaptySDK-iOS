//
//  PaywallViewEvent.DidUserAction.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension PaywallViewEvent {
    struct DidUserAction: AdaptyPluginEvent {
        let id = "paywall_view_did_perform_action"
        let view: AdaptyUI.PaywallView
        let action: AdaptyUI.Action

        enum CodingKeys: CodingKey {
            case id
            case view
            case action
        }
    }
}

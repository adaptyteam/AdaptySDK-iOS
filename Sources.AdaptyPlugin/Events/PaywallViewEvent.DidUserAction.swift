//
//  PaywallViewEvent.DidUserAction.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

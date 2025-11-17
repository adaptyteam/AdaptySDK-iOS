//
//  PaywallViewEvent.DidFailRendering.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension PaywallViewEvent {
    struct DidFailRendering: AdaptyPluginEvent {
        let id = "paywall_view_did_fail_rendering"
        let view: AdaptyUI.PaywallView
        let error: AdaptyUIError

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case error
        }
    }
}

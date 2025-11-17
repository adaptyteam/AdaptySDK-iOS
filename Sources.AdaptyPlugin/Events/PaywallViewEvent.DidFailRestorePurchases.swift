//
//  PaywallViewEvent.DidFailRestorePurchases.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 21.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension PaywallViewEvent {
    struct DidFailRestorePurchases: AdaptyPluginEvent {
        let id = "paywall_view_did_fail_restore"
        let view: AdaptyUI.PaywallView
        let error: AdaptyError

        enum CodingKeys: CodingKey {
            case id
            case view
            case error
        }
    }
}

//
//  PaywallViewEvent.DidRestorePurchases.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension PaywallViewEvent {
    struct DidRestorePurchases: AdaptyPluginEvent {
        let id = "paywall_view_did_finish_restore"
        let view: AdaptyUI.PaywallView
        let profile: AdaptyProfile

        enum CodingKeys: CodingKey {
            case id
            case view
            case profile
        }
    }
}

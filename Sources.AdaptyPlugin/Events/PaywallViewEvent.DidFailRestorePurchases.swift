//
//  PaywallViewEvent.DidFailRestorePurchases.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 21.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

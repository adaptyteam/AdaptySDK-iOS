//
//  PaywallViewEvent.WillRestorePurchases.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension PaywallViewEvent {
    struct WillRestorePurchases: AdaptyPluginEvent {
        let id = "paywall_view_did_start_restore"
        let view: AdaptyUI.PaywallView

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

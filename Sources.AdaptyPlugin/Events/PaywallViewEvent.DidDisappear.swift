//
//  PaywallViewEvent.DidDisappear.swift
//  AdaptyPlugin
//
//  Created by Alexey Goncharov on 3/13/25.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension PaywallViewEvent {
    struct DidDisappear: AdaptyPluginEvent {
        let id = "paywall_view_did_disappear"
        let view: AdaptyUI.PaywallView

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

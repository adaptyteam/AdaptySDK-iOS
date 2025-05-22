//
//  Request.AdaptyUICreatePaywallView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Request {
    struct AdaptyUICreatePaywallView: AdaptyPluginRequest {
        static let method = "adapty_ui_create_paywall_view"

        let paywall: AdaptyPaywall
        let loadTimeout: TimeInterval?
        let preloadProducts: Bool?
        let customTags: [String: String]?
        let customTimers: [String: Date]?

        enum CodingKeys: String, CodingKey {
            case paywall
            case loadTimeout = "load_timeout"
            case preloadProducts = "preload_products"
            case customTags = "custom_tags"
            case customTimers = "custom_timers"
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(await AdaptyUI.Plugin.createPaywallView(
                paywall: paywall,
                loadTimeout: loadTimeout,
                preloadProducts: preloadProducts ?? false,
                tagResolver: customTags,
                timerResolver: customTimers
            ))
        }
    }
}


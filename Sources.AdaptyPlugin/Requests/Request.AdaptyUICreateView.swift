//
//  Request.AdaptyUICreateView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Request {
    struct AdaptyUICreateView: AdaptyPluginRequest {
        static let method = "adapty_ui_create_view"

        let paywall: AdaptyPaywall
        let loadTimeout: TimeInterval?
        let preloadProducts: Bool
        let customTags: [String: String]?
        let customTimers: [String: Date]?

        enum CodingKeys: String, CodingKey {
            case paywall
            case loadTimeout = "load_timeout"
            case preloadProducts = "preload_products"
            case customTags = "custom_tags"
            case customTimers = "custom_timers"
        }

        init(from params: AdaptyJsonDictionary) throws {
            try self.init(
                paywall: params.value(forKey: CodingKeys.paywall),
                loadTimeout: params.valueIfPresent(TimeInterval.self, forKey: CodingKeys.loadTimeout),
                preloadProducts: params.valueIfPresent(Bool.self, forKey: CodingKeys.preloadProducts),
                customTags: params.valueIfPresent(forKey: CodingKeys.customTags),
                customTimers: params.valueIfPresent(forKey: CodingKeys.customTimers)
            )
        }

        init(
            paywall: KeyValue,
            loadTimeout: TimeInterval?,
            preloadProducts: Bool?,
            customTags: KeyValue?,
            customTimers: KeyValue?
        ) throws {
            self.paywall = try paywall.decode(AdaptyPaywall.self)
            self.loadTimeout = loadTimeout
            self.preloadProducts = preloadProducts ?? false
            self.customTags = try customTags?.decode([String: String].self)
            self.customTimers = try customTags?.decode([String: Date].self)
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(await AdaptyUI.Plugin.createView(
                paywall: paywall,
                loadTimeout: loadTimeout,
                preloadProducts: preloadProducts,
                tagResolver: customTags,
                timerResolver: customTimers,
                delegate: Adapty.PluginDelegate.shared
            ))
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyPlugin {
    @objc static func adaptyUICreateView(
        paywall: String,
        loadTimeout: Double,
        preloadProducts: Bool,
        customTags: String?,
        customTimers: String?,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.AdaptyUICreateView.CodingKeys
        execute(with: completion) { try Request.AdaptyUICreateView(
            paywall: KeyValue(key: CodingKeys.paywall, value: paywall),
            loadTimeout: loadTimeout,
            preloadProducts: preloadProducts,
            customTags: customTags.map { KeyValue(key: CodingKeys.customTags, value: $0) },
            customTimers: customTimers.map { KeyValue(key: CodingKeys.customTimers, value: $0) }
        ) }
    }
}

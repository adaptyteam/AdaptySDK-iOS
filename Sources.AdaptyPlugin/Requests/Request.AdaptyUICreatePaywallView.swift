//
//  Request.AdaptyUICreatePaywallView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

#if canImport(UIKit)

import Adapty
import AdaptyUI
import AdaptyUIBuilder
import Foundation

public extension [AdaptyCustomAsset.Identifiable] {
    @MainActor
    func assetsResolver() throws -> [String: AdaptyCustomAsset]? {
        guard !isEmpty else { return nil }

        var assetsResolver = [String: AdaptyCustomAsset]()
        assetsResolver.reserveCapacity(count)

        for asset in self {
            switch asset.value {
            case .asset(let value):
                assetsResolver[asset.id] = value
            case .imageFlutterAssetId(let assetId):
                assetsResolver[asset.id] = try .image(.file(url: url(assetId)))
            case .videoFlutterAssetId(let assetId):
                assetsResolver[asset.id] = try .video(.file(url: url(assetId), preview: nil))
            }
        }

        return assetsResolver

        func url(_ assetId: String) throws -> URL {
            guard let assetIdToFileURL = AdaptyPlugin.assetIdToFileURL else {
                throw AdaptyPluginInternalError.unregister("Unregister assetIdToFileURL in AdaptyPlugin")
            }
            guard let url = assetIdToFileURL(assetId) else {
                throw AdaptyPluginInternalError.notExist("Asset \(assetId) not found")
            }

            return url
        }
    }
}

extension Request {
    struct AdaptyUICreatePaywallView: AdaptyPluginRequest {
        static let method = "adapty_ui_create_paywall_view"

        let paywall: AdaptyPaywall
        let loadTimeout: TimeInterval?
        let preloadProducts: Bool?
        let customTags: [String: String]?
        let customTimers: [String: Date]?
        let customAssets: [AdaptyUICustomAsset.Identifiable]?

        enum CodingKeys: String, CodingKey {
            case paywall
            case loadTimeout = "load_timeout"
            case preloadProducts = "preload_products"
            case customTags = "custom_tags"
            case customTimers = "custom_timers"
            case customAssets = "custom_assets"
        }

        func execute() async throws -> AdaptyJsonData {
            try await executeInMainActor()
        }

        @MainActor
        func executeInMainActor() async throws -> AdaptyJsonData {
            let result: AdaptyUI.PaywallView = try await AdaptyUI.Plugin.createPaywallView(
                paywall: paywall,
                loadTimeout: loadTimeout,
                preloadProducts: preloadProducts ?? false,
                tagResolver: customTags,
                timerResolver: customTimers,
                assetsResolver: assetsResolver()
            )

            return .success(result)
        }

        @MainActor
        func assetsResolver() throws -> [String: AdaptyUICustomAsset]? {
            guard let customAssets, !customAssets.isEmpty else { return nil }

            var assetsResolver: [String: AdaptyUICustomAsset] = [:]
            assetsResolver.reserveCapacity(customAssets.count)

            for asset in customAssets {
                switch asset.value {
                case .asset(let value):
                    assetsResolver[asset.id] = value
                case .imageFlutterAssetId(let assetId):
                    assetsResolver[asset.id] = try .image(.file(url: url(assetId)))
                case .videoFlutterAssetId(let assetId):
                    assetsResolver[asset.id] = try .video(.file(url: url(assetId), preview: nil))
                }
            }

            return assetsResolver

            func url(_ assetId: String) throws -> URL {
                guard let assetIdToFileURL = AdaptyPlugin.assetIdToFileURL else {
                    throw AdaptyPluginInternalError.unregister("Unregister assetIdToFileURL in AdaptyPlugin")
                }
                guard let url = assetIdToFileURL(assetId) else {
                    throw AdaptyPluginInternalError.notExist("Asset \(assetId) not found")
                }

                return url
            }
        }
    }
}

public extension AdaptyPlugin {
    @MainActor
    fileprivate static var assetIdToFileURL: (@MainActor (String) -> URL?)?

    @MainActor
    static func register(createPaywallView: @MainActor @escaping (String) -> URL?) {
        assetIdToFileURL = createPaywallView
    }
}

#endif

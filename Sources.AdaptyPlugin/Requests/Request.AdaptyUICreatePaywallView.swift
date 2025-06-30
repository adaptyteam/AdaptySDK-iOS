//
//  Request.AdaptyUICreatePaywallView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

#if canImport(UIKit)

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
        let customAssets: [AdaptyCustomAsset.Identifiable]?

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
            try .success(await AdaptyUI.Plugin.createPaywallView(
                paywall: paywall,
                loadTimeout: loadTimeout,
                preloadProducts: preloadProducts ?? false,
                tagResolver: customTags,
                timerResolver: customTimers,
                assetsResolver: assetsResolver()
            ))
        }

        @MainActor
        func assetsResolver() throws -> [String: AdaptyCustomAsset]? {
            guard let customAssets, !customAssets.isEmpty else { return nil }

            var assetsResolver = [String: AdaptyCustomAsset]()
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
                guard let assetIdToFileURL = Self.assetIdToFileURL else {
                    throw AdaptyPluginInternalError.unregister("Unregister assetIdToFileURL in AdaptyPlugin")
                }
                guard let url = assetIdToFileURL(assetId) else {
                    throw AdaptyPluginInternalError.notExist("Asset \(assetId) not found")
                }

                return url
            }
        }

        @MainActor
        fileprivate static var assetIdToFileURL: (@MainActor (String) -> URL?)?
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyPlugin {
    @MainActor
    static func register(createPaywallView: @MainActor @escaping (String) -> URL?) {
        Request.AdaptyUICreatePaywallView.assetIdToFileURL = createPaywallView
    }
}

#endif
